import Cocoa

// Initialize NSApplication to ensure graphics context works
let _ = NSApplication.shared

let size = CGSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

// 1. Fill White Background
NSColor.white.setFill()
NSRect(origin: .zero, size: size).fill()

// 2. Setup Context
guard let ctx = NSGraphicsContext.current?.cgContext else {
    print("Error: No graphics context")
    exit(1)
}
ctx.setFillColor(NSColor.black.cgColor)
ctx.setStrokeColor(NSColor.black.cgColor)

let center = CGPoint(x: 512, y: 512)
let sunRadius: CGFloat = 200.0
let rayLength: CGFloat = 160.0
let rayWidth: CGFloat = 60.0
let numberOfRays = 8

// 3. Draw Rays
ctx.saveGState()
ctx.translateBy(x: center.x, y: center.y)

for i in 0..<numberOfRays {
    let angle = (CGFloat(i) * (2.0 * .pi)) / CGFloat(numberOfRays)
    ctx.saveGState()
    ctx.rotate(by: angle)
    
    // Draw ray (Rect)
    // Start a bit outside the sun
    let rayRect = CGRect(x: -rayWidth/2, y: sunRadius + 40, width: rayWidth, height: rayLength)
    ctx.fill(rayRect)
    
    ctx.restoreGState()
}
ctx.restoreGState()

// 4. Draw Sun Body (Center Circle)
let sunRect = CGRect(x: center.x - sunRadius, y: center.y - sunRadius, width: sunRadius * 2, height: sunRadius * 2)
ctx.fillEllipse(in: sunRect)

image.unlockFocus()

// 5. Save to Disk
if let tiffData = image.tiffRepresentation,
   let bitmap = NSBitmapImageRep(data: tiffData),
   let pngData = bitmap.representation(using: .png, properties: [:]) {
    let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath).appendingPathComponent("app_icon_sun.png")
    do {
        try pngData.write(to: url)
        print("Icon generated at: \(url.path)")
    } catch {
        print("Error writing file: \(error)")
        exit(1)
    }
} else {
    print("Error creating representation")
    exit(1)
}
