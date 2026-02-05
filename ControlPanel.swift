import Cocoa

class CalibrationPanel: NSPanel {
    
    private var rgbSlider: NSSlider!
    private var alphaSlider: NSSlider!
    private var rgbLabel: NSTextField!
    private var alphaLabel: NSTextField!
    
    // Callbacks
    var onRGBChanged: ((Float) -> Void)?
    var onAlphaChanged: ((Float) -> Void)?
    
    init() {
        super.init(contentRect: NSRect(x: 100, y: 100, width: 300, height: 200),
                   styleMask: [.titled, .closable, .hudWindow, .utilityWindow, .nonactivatingPanel],
                   backing: .buffered,
                   defer: false)
        
        self.title = "EDR Calibration"
        self.isFloatingPanel = true
        self.level = .floating
        self.contentView?.wantsLayer = true
        
        setupUI()
    }
    
    private func setupUI() {
        let stackView = NSStackView()
        stackView.orientation = .vertical
        stackView.spacing = 20
        stackView.edgeInsets = NSEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        stackView.alignment = .leading
        
        // --- RGB Slider Section ---
        let rgbTitle = NSTextField(labelWithString: "Brightness (Signal Strength)")
        rgbTitle.font = NSFont.boldSystemFont(ofSize: 12)
        
        // Default: 850.9
        rgbSlider = NSSlider(value: 850.9, minValue: 0.0, maxValue: 2000.0, target: self, action: #selector(sliderChanged))
        rgbSlider.widthAnchor.constraint(equalToConstant: 260).isActive = true
        
        rgbLabel = NSTextField(labelWithString: "Value: 850.9")
        
        stackView.addArrangedSubview(rgbTitle)
        stackView.addArrangedSubview(rgbSlider)
        stackView.addArrangedSubview(rgbLabel)
        
        // --- Alpha Slider Section ---
        let alphaTitle = NSTextField(labelWithString: "Transparency (Lower = Clearer)")
        alphaTitle.font = NSFont.boldSystemFont(ofSize: 12)
        
        // Default: 0.0000435
        alphaSlider = NSSlider(value: 0.0000435, minValue: 0.0, maxValue: 0.001, target: self, action: #selector(sliderChanged))
        alphaSlider.widthAnchor.constraint(equalToConstant: 260).isActive = true
        
        alphaLabel = NSTextField(labelWithString: "Value: 0.0000435")
        
        stackView.addArrangedSubview(alphaTitle)
        stackView.addArrangedSubview(alphaSlider)
        stackView.addArrangedSubview(alphaLabel)
        
        self.contentView?.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: self.contentView!.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: self.contentView!.centerYAnchor)
        ])
    }
    
    @objc private func sliderChanged() {
        let rgb = rgbSlider.floatValue
        let alpha = alphaSlider.floatValue
        
        rgbLabel.stringValue = String(format: "Value: %.1f nits", rgb)
        alphaLabel.stringValue = String(format: "Value: %.7f", alpha)
        
        onRGBChanged?(rgb)
        onAlphaChanged?(alpha)
    }
}
