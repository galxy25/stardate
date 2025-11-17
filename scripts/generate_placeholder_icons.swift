#!/usr/bin/env swift

import Foundation
import AppKit

// Create placeholder icons for visionOS Solid Image Stack
// Each icon will be clearly labeled to verify they're being used

func createPlaceholderIcon(size: Int, label: String, backgroundColor: NSColor, textColor: NSColor) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()

    // Fill background
    backgroundColor.setFill()
    NSRect(x: 0, y: 0, width: size, height: size).fill()

    // Draw label text
    let font = NSFont.boldSystemFont(ofSize: CGFloat(size) / 4)
    let attributes: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: textColor
    ]

    let attributedString = NSAttributedString(string: label, attributes: attributes)
    let textSize = attributedString.size()
    let textRect = NSRect(
        x: (CGFloat(size) - textSize.width) / 2,
        y: (CGFloat(size) - textSize.height) / 2,
        width: textSize.width,
        height: textSize.height
    )

    attributedString.draw(in: textRect)

    image.unlockFocus()
    return image
}

func saveImage(_ image: NSImage, to path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmapImage = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        print("Error: Failed to convert image to PNG")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("✓ Created: \(path)")
    } catch {
        print("Error: Failed to write image to \(path): \(error)")
    }
}

// Main execution
let basePath = "/Users/levischoen/forges/stardate/StarDate/StarDate/Assets.xcassets/AppIcon.solidimagestack"

// Create directory structure
let directories = [
    "\(basePath)/Front.solidimagestacklayer/Content.imageset",
    "\(basePath)/Middle.solidimagestacklayer/Content.imageset",
    "\(basePath)/Back.solidimagestacklayer/Content.imageset"
]

for dir in directories {
    try? FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
}

// Generate placeholder icons (1024x1024)
// Using 1024x1024 to avoid Xcode crashes with large images
let size = 1024

// Front layer - bright cyan with "FRONT" label
let frontIcon = createPlaceholderIcon(
    size: size,
    label: "FRONT",
    backgroundColor: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0), // Cyan
    textColor: NSColor.black
)
saveImage(frontIcon, to: "\(basePath)/Front.solidimagestacklayer/Content.imageset/icon.png")

// Middle layer - medium blue with "MIDDLE" label
let middleIcon = createPlaceholderIcon(
    size: size,
    label: "MIDDLE",
    backgroundColor: NSColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0), // Blue
    textColor: NSColor.white
)
saveImage(middleIcon, to: "\(basePath)/Middle.solidimagestacklayer/Content.imageset/icon.png")

// Back layer - dark purple with "BACK" label
let backIcon = createPlaceholderIcon(
    size: size,
    label: "BACK",
    backgroundColor: NSColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0), // Dark purple
    textColor: NSColor(red: 0.0, green: 1.0, blue: 1.0, alpha: 1.0) // Cyan text
)
saveImage(backIcon, to: "\(basePath)/Back.solidimagestacklayer/Content.imageset/icon.png")

print("\n✅ Placeholder icons generated successfully!")
print("   Front: Bright cyan")
print("   Middle: Medium blue")
print("   Back: Dark purple")
