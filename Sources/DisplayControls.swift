import Cocoa

class DisplayControls {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var overlayWindow: OverlayWindow?
    private var calibrationPanel: CalibrationPanel? // New Floating Panel
    private var isEnabled: Bool = false
    
    // State Tracking
    // User Verified Defaults
    private var currentRGB: Float = 850.9
    private var currentAlpha: Float = 0.0000435
    
    // UserDefaults Keys
    private let keyEnabled = "OpenBright_IsEnabled"
    private let keyRGB = "OpenBright_RGB"
    private let keyAlpha = "OpenBright_Alpha"
    
    init() {
        statusBar = NSStatusBar.system
        statusItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "sun.max", accessibilityDescription: "Brightness")
            button.action = #selector(toggleBrightness)
            button.target = self
        }
        
        constructMenu()
        
        // Initialize Overlay
        overlayWindow = OverlayWindow()
        
        // Initialize Controllers
        calibrationPanel = CalibrationPanel()
        
        // Load Defaults
        loadPreferences()
        
        // Wire up callbacks
        calibrationPanel?.onRGBChanged = { [weak self] rgb in
            self?.currentRGB = rgb
            self?.savePreferences()
            self?.updateOverlay()
        }
        
        calibrationPanel?.onAlphaChanged = { [weak self] alpha in
            self?.currentAlpha = alpha
            self?.savePreferences()
            self?.updateOverlay()
        }
        
        // Apply Initial State
        if isEnabled {
            enableHighBrightness()
        } else {
             // Ensure icon is correct state
             updateStatusIcon()
        }
        
        startBatteryMonitoring()
        
        // Feedback on Launch
        showLaunchNotification()
    }
    
    private func showLaunchNotification() {
        // Only show if NOT enabled, because if it IS enabled, the screen brightness change is feedback enough
        // and we don't want to annoy the user.
        if !isEnabled {
            let notification = NSUserNotification()
            notification.title = "OpenBright Ready"
            notification.informativeText = "The app is running in your menu bar. Click the ☼ icon to control it."
            notification.soundName = nil // Silent
            NSUserNotificationCenter.default.deliver(notification)
        }
    }
    
    private func loadPreferences() {
        let defaults = UserDefaults.standard
        
        // Check if keys exist (first run check)
        if defaults.object(forKey: keyRGB) != nil {
            currentRGB = defaults.float(forKey: keyRGB)
        }
        
        if defaults.object(forKey: keyAlpha) != nil {
            currentAlpha = defaults.float(forKey: keyAlpha)
        }
        
        isEnabled = defaults.bool(forKey: keyEnabled)
    }
    
    private func savePreferences() {
        let defaults = UserDefaults.standard
        defaults.set(currentRGB, forKey: keyRGB)
        defaults.set(currentAlpha, forKey: keyAlpha)
        defaults.set(isEnabled, forKey: keyEnabled)
    }
    
    private func updateOverlay() {
        overlayWindow?.edrView?.updateParameters(rgb: currentRGB, alpha: currentAlpha)
    }
    
    private func constructMenu() {
        let menu = NSMenu()
        
        let toggleItem = NSMenuItem(title: "Toggle High Brightness", action: #selector(toggleBrightness), keyEquivalent: "b")
        toggleItem.target = self
        menu.addItem(toggleItem)
        
        let splitItem = NSMenuItem(title: "Split Screen Comparison", action: #selector(toggleSplitScreen), keyEquivalent: "s")
        splitItem.target = self
        menu.addItem(splitItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let calibItem = NSMenuItem(title: "Show Calibration Controls...", action: #selector(showCalibration), keyEquivalent: "c")
        calibItem.target = self
        menu.addItem(calibItem)
        
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        
        statusItem.menu = menu
    }
    
    @objc func showCalibration() {
        calibrationPanel?.makeKeyAndOrderFront(nil)
        
        // Ensure overlay is on if they are calibrating
        if !isEnabled {
            toggleBrightness()
        }
    }
    
    @objc func toggleBrightness() {
        isEnabled.toggle()
        savePreferences()
        
        if isEnabled {
            enableHighBrightness()
        } else {
            disableHighBrightness()
        }
    }
    
    private func updateStatusIcon() {
        if let button = statusItem.button {
             button.image = NSImage(systemSymbolName: isEnabled ? "sun.max.fill" : "sun.max", accessibilityDescription: "Brightness")
        }
    }
    
    private func enableHighBrightness() {
        print("Enabling High Brightness Mode")
        updateStatusIcon()
        if let screen = NSScreen.main {
            print("Max Potential EDR: \(screen.maximumPotentialExtendedDynamicRangeColorComponentValue)")
            print("Current Max EDR: \(screen.maximumExtendedDynamicRangeColorComponentValue)")
        }
        
        // Apply current parameters before enabling
        overlayWindow?.edrView?.updateParameters(rgb: currentRGB, alpha: currentAlpha)
        overlayWindow?.enable()
    }
    
    private func disableHighBrightness() {
        print("Disabling High Brightness Mode")
        updateStatusIcon()
        overlayWindow?.disable()
    }
    
    @objc func toggleSplitScreen() {
        // Automatically enable brightness if it's not already on
        if !isEnabled {
            toggleBrightness()
        }
        overlayWindow?.toggleSplitScreen()
    }

    // MARK: - Battery Protection
    private var batteryTimer: Timer?
    
    private func startBatteryMonitoring() {
        // Check every 60 seconds
        batteryTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(checkBatteryStatus), userInfo: nil, repeats: true)
        // Check immediately too
        checkBatteryStatus()
    }
    
    @objc private func checkBatteryStatus() {
        // Only enforce if currently enabled
        guard isEnabled else { return }
        
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
        process.arguments = ["-g", "batt"]
        
        let pipe = Pipe()
        process.standardOutput = pipe
        
        do {
            try process.run()
            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            if let output = String(data: data, encoding: .utf8) {
                // simple parsing
                let isOnBattery = output.contains("Now drawing from 'Battery Power'")
                
                if isOnBattery {
                    // Find percentage
                    // Output format example: ... 55%; discharging; ... or ... 100%; charged; ...
                    if let range = output.range(of: "\\d+%", options: .regularExpression) {
                        let percentString = output[range].dropLast() // remove %
                        if let percent = Int(percentString) {
                            if percent < 20 {
                                print("Battery Protection: Level is \(percent)% and on battery. Disabling.")
                                disableHighBrightness()
                                isEnabled = false
                                savePreferences()
                                updateStatusIcon()
                                showLowBatteryNotification()
                            }
                        }
                    }
                }
            }
        } catch {
            print("Failed to check battery status: \(error)")
        }
    }
    
    private func showLowBatteryNotification() {
        let notification = NSUserNotification()
        notification.title = "High Brightness Disabled"
        notification.informativeText = "Battery is below 20%. Disabling XDR boost to preserve power."
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
}
