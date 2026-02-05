import Cocoa
import Metal
import QuartzCore

class EDRView: NSView {
    private var metalLayer: CAMetalLayer?
    private var device: MTLDevice?
    private var commandQueue: MTLCommandQueue?
    private var timer: Timer?
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupMetal()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupMetal()
    }
    
    private func setupMetal() {
        self.wantsLayer = true
        
        let layer = CAMetalLayer()
        self.layer = layer
        self.metalLayer = layer
        
        layer.wantsExtendedDynamicRangeContent = true
        
        // Use standard EDR format
        layer.pixelFormat = .rgba16Float
        layer.colorspace = CGColorSpace(name: CGColorSpace.extendedLinearDisplayP3)

        // Make it transparent
        layer.isOpaque = false
        layer.backgroundColor = NSColor.clear.cgColor
        
        device = MTLCreateSystemDefaultDevice()
        layer.device = device
        commandQueue = device?.makeCommandQueue()
    }
    
    func start() {
        if timer == nil {
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.render()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    // Tuner State
    // User Verified Defaults (High Intensity)
    private var currentRGB: Float = 850.9
    private var currentAlpha: Float = 0.0000435
    
    // Public API for Control Panel
    func updateParameters(rgb: Float, alpha: Float) {
        self.currentRGB = rgb
        self.currentAlpha = alpha
        
        // Force immediate render
        render()
    }
    
    private func render() {
        guard let layer = metalLayer,
              let drawable = layer.nextDrawable(),
              let queue = commandQueue,
              let buffer = queue.makeCommandBuffer() else {
            return
        }
        
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.texture
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        
        // Interactive Value from Control Panel
        renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: Double(currentRGB), green: Double(currentRGB), blue: Double(currentRGB), alpha: Double(currentAlpha))
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        
        let encoder = buffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        encoder?.endEncoding()
        
        buffer.present(drawable)
        buffer.commit()
    }
}
