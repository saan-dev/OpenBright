import Cocoa

class OverlayWindow: NSWindow {
    var edrView: EDRView?

    init() {
        // Start with a default rect, will be updated in enable()
        let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 100, height: 100)
        
        super.init(contentRect: screenRect,
                   styleMask: [.borderless],
                   backing: .buffered,
                   defer: false)
        
        self.level = .mainMenu 
        self.backgroundColor = .clear
        self.isOpaque = false
        self.hasShadow = false
        
        // IMPORTANT: For Production, we MUST ignore events to let clicks pass through!
        self.ignoresMouseEvents = true 
        
        self.collectionBehavior = [.canJoinAllSpaces, .stationary]
        
        // Initialize Metal View
        edrView = EDRView(frame: screenRect)
        self.contentView = edrView
        
        // Initial state is hidden/disabled
        self.orderOut(nil)
    }
    
    private var isSplitScreen = false

    func enable() {
        updateFrame()
        self.makeKeyAndOrderFront(nil)
        self.makeFirstResponder(edrView)
        edrView?.start()
    }
    
    func toggleSplitScreen() {
        isSplitScreen.toggle()
        updateFrame()
    }
    
    private func updateFrame() {
        guard let screen = NSScreen.main else { return }
        
        var newFrame = screen.frame
        if isSplitScreen {
            // Right Half Only
            newFrame = NSRect(x: screen.frame.width / 2, 
                              y: 0, 
                              width: screen.frame.width / 2, 
                              height: screen.frame.height)
        }
        
        self.setFrame(newFrame, display: true)
        edrView?.frame = NSRect(x: 0, y: 0, width: newFrame.width, height: newFrame.height)
    }
    
    override var canBecomeKey: Bool { return true }
    override var canBecomeMain: Bool { return true }
    
    func disable() {
        self.orderOut(nil)
        edrView?.stop()
    }
}
