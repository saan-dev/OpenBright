import Cocoa

class StatusBarController {
    private var statusBar: NSStatusBar
    private var statusItem: NSStatusItem
    private var overlayWindow: OverlayWindow?
    private var calibrationPanel: CalibrationPanel? // New Floating Panel
    private var isEnabled: Bool = false
    
    // State Tracking
    // User Verified Defaults
    private var currentRGB: Float = 850.9
    private var currentAlpha: Float = 0.0000435
    
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
        
        // Wire up callbacks
        calibrationPanel?.onRGBChanged = { [weak self] rgb in
            self?.currentRGB = rgb
            self?.updateOverlay()
        }
        
        calibrationPanel?.onAlphaChanged = { [weak self] alpha in
            self?.currentAlpha = alpha
            self?.updateOverlay()
        }
        
        // Auto-show calibration removed for final version
        // showCalibration()
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
        
        if let button = statusItem.button {
             button.image = NSImage(systemSymbolName: isEnabled ? "sun.max.fill" : "sun.max", accessibilityDescription: "Brightness")
        }
        
        if isEnabled {
            print("Enabling High Brightness Mode")
            if let screen = NSScreen.main {
                print("Max Potential EDR: \(screen.maximumPotentialExtendedDynamicRangeColorComponentValue)")
                print("Current Max EDR: \(screen.maximumExtendedDynamicRangeColorComponentValue)")
            }
            overlayWindow?.enable()
        } else {
            print("Disabling High Brightness Mode")
            overlayWindow?.disable()
        }
    }
    
    @objc func toggleSplitScreen() {
        // Automatically enable brightness if it's not already on
        if !isEnabled {
            toggleBrightness()
        }
        overlayWindow?.toggleSplitScreen()
    }
}
