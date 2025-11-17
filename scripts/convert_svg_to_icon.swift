#!/usr/bin/env swift

import Foundation
import AppKit

// Convert SVG to PNG icons for visionOS Solid Image Stack
// Creates Front, Middle (blurred), and Back (background only) layers

func loadSVG(from path: String) -> NSImage? {
    guard let image = NSImage(contentsOfFile: path) else {
        print("Error: Could not load SVG from \(path)")
        return nil
    }
    return image
}

func renderImage(_ image: NSImage, size: NSSize) -> NSImage {
    let outputImage = NSImage(size: size)
    outputImage.lockFocus()

    NSGraphicsContext.current?.imageInterpolation = .high
    image.draw(in: NSRect(origin: .zero, size: size),
               from: NSRect(origin: .zero, size: image.size),
               operation: .sourceOver,
               fraction: 1.0)

    outputImage.unlockFocus()
    return outputImage
}

func applyBlur(to image: NSImage, radius: CGFloat) -> NSImage {
    // Create a blurred version using Core Image
    guard let tiffData = image.tiffRepresentation,
          let ciImage = CIImage(data: tiffData) else {
        return image
    }

    let filter = CIFilter(name: "CIGaussianBlur")
    filter?.setValue(ciImage, forKey: kCIInputImageKey)
    filter?.setValue(radius, forKey: kCIInputRadiusKey)

    guard let outputImage = filter?.outputImage else {
        return image
    }

    let context = CIContext()
    guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
        return image
    }

    return NSImage(cgImage: cgImage, size: image.size)
}

func extractBackground(from image: NSImage) -> NSImage {
    // Create a version with just the background gradient
    // This is a simplified version - we'll create a dark gradient background
    let outputImage = NSImage(size: image.size)
    outputImage.lockFocus()

    // Create radial gradient matching the SVG background
    let gradient = NSGradient(colors: [
        NSColor(red: 0.04, green: 0.04, blue: 0.10, alpha: 1.0),  // #0a0a1a
        NSColor(red: 0.10, green: 0.10, blue: 0.23, alpha: 1.0),  // #1a1a3a
        NSColor(red: 0.16, green: 0.16, blue: 0.35, alpha: 1.0),  // #2a2a5a
        NSColor(red: 0.04, green: 0.04, blue: 0.10, alpha: 1.0)   // #0a0a1a
    ])

    let center = NSPoint(x: image.size.width / 2, y: image.size.height / 2)
    gradient?.draw(fromCenter: center, radius: 0, toCenter: center, radius: image.size.width / 2, options: [])

    outputImage.unlockFocus()
    return outputImage
}

func saveImage(_ image: NSImage, to path: String, forceOpaque: Bool = false) {
    guard let tiffData = image.tiffRepresentation,
          var bitmapImage = NSBitmapImageRep(data: tiffData) else {
        print("Error: Failed to convert image to PNG")
        return
    }

    // If forceOpaque is true, ensure the image has no alpha channel
    if forceOpaque {
        // Create a new bitmap without alpha
        let opaqueBitmap = NSBitmapImageRep(
            bitmapDataPlanes: nil,
            pixelsWide: Int(bitmapImage.size.width),
            pixelsHigh: Int(bitmapImage.size.height),
            bitsPerSample: 8,
            samplesPerPixel: 3,
            hasAlpha: false,
            isPlanar: false,
            colorSpaceName: .deviceRGB,
            bytesPerRow: 0,
            bitsPerPixel: 0
        )!

        // Draw the original image onto the opaque bitmap
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: opaqueBitmap)
        image.draw(in: NSRect(origin: .zero, size: image.size))
        NSGraphicsContext.restoreGraphicsState()

        bitmapImage = opaqueBitmap
    }

    guard let pngData = bitmapImage.representation(using: .png, properties: [:]) else {
        print("Error: Failed to convert image to PNG")
        return
    }

    do {
        try pngData.write(to: URL(fileURLWithPath: path))
        print("✓ Created: \(path)\(forceOpaque ? " (opaque)" : "")")
    } catch {
        print("Error: Failed to write image to \(path): \(error)")
    }
}

// Main execution
let svgPath = "/Users/levischoen/forges/stardate/Assets/AppIcon.svg"
let basePath = "/Users/levischoen/forges/stardate/StarDate/StarDate/Assets.xcassets/AppIcon.solidimagestack"
// Use 1024x1024 to avoid Xcode crashes with large images
let size = NSSize(width: 1024, height: 1024)

print("🎨 Converting SVG to visionOS icon layers...")

// Load SVG
guard let svgImage = loadSVG(from: svgPath) else {
    print("❌ Failed to load SVG file")
    exit(1)
}

print("✓ Loaded SVG file")

// Render to 1024x1024
let fullIcon = renderImage(svgImage, size: size)
print("✓ Rendered full icon at 1024x1024")

// Front layer: Full icon
let frontIcon = fullIcon
saveImage(frontIcon, to: "\(basePath)/Front.solidimagestacklayer/Content.imageset/icon.png")

// Middle layer: Slightly blurred version for depth, but fully opaque
// For visionOS, the Middle layer must be fully opaque (no transparency)
let middleIconBlurred = applyBlur(to: fullIcon, radius: 3.0)
// Ensure it's fully opaque by compositing on a solid background
let middleIcon = NSImage(size: size)
middleIcon.lockFocus()
// Fill with opaque background matching the icon
NSColor(red: 0.04, green: 0.04, blue: 0.10, alpha: 1.0).setFill()
NSRect(origin: .zero, size: size).fill()
// Draw the blurred icon on top
middleIconBlurred.draw(in: NSRect(origin: .zero, size: size), from: NSRect(origin: .zero, size: middleIconBlurred.size), operation: .sourceOver, fraction: 1.0)
middleIcon.unlockFocus()
saveImage(middleIcon, to: "\(basePath)/Middle.solidimagestacklayer/Content.imageset/icon.png", forceOpaque: true)

// Back layer: Background only
let backIcon = extractBackground(from: fullIcon)
saveImage(backIcon, to: "\(basePath)/Back.solidimagestacklayer/Content.imageset/icon.png")

print("\n✅ Successfully created all icon layers!")
print("   Front: Full starfield warp icon")
print("   Middle: Blurred version for depth")
print("   Back: Dark gradient background")
