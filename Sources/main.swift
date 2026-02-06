import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var displayControls: DisplayControls?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Create the status bar controller
        displayControls = DisplayControls()
    }
}

// Entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
