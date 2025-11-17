# App Icon Generation Guide

This guide explains how to use the provided assets to create the StarDate app icon.

## Icon Design

The icon features a **starfield accelerating to warp** with:
- Dark space background with radial gradient
- Cyan/turquoise warp lines converging to center
- Stars of varying sizes creating depth
- Motion blur streaks showing acceleration
- Bright center point representing the warp destination

## Method 1: Using the SVG File

### Step 1: Open the SVG
1. Open `AppIcon.svg` in a vector graphics editor:
   - **macOS**: Preview, Affinity Designer, Adobe Illustrator, or Inkscape
   - **Online**: Figma, Canva, or SVG editors

### Step 2: Export to PNG
For visionOS, you need multiple sizes. Export at these resolutions:

- **1024x1024** - Main app icon
- **512x512** - Alternative size
- **256x256** - Smaller variant

### Step 3: Add to Xcode
1. Open your Xcode project
2. Navigate to `Assets.xcassets`
3. Select `AppIcon`
4. Drag and drop the PNG files into the appropriate slots

## Method 2: Using SwiftUI View (Programmatic)

### Step 1: Use the Preview
1. Open `AppIconView.swift` in Xcode
2. Click the **Preview** button (or press `⌘⌥↩`)
3. The preview will show the icon at 1024x1024

### Step 2: Export from Preview
1. Right-click on the preview
2. Select **Export** or take a screenshot
3. Save as PNG at 1024x1024 resolution

### Step 3: Alternative - Create Export Script

Create a macOS app or script that renders the view:

```swift
import SwiftUI

let renderer = ImageRenderer(content: AppIconView())
renderer.scale = 2.0 // For retina

if let image = renderer.uiImage {
    // Save image
    if let data = image.pngData() {
        try? data.write(to: URL(fileURLWithPath: "/path/to/icon.png"))
    }
}
```

## Method 3: Using Xcode's Icon Generator

### Step 1: Create Icon Set
1. In Xcode, select `Assets.xcassets`
2. Right-click and select **New Image Set**
3. Name it `AppIcon`

### Step 2: Add Images
1. Drag the 1024x1024 PNG into the **Universal** slot
2. Xcode will automatically generate all required sizes

## visionOS Icon Requirements

visionOS uses a **Solid Image Stack** format:

1. **Front Layer** (1024x1024): Main icon content
2. **Middle Layer** (1024x1024): Optional depth layer
3. **Back Layer** (1024x1024): Background layer

### Creating Solid Image Stack

1. In `Assets.xcassets`, select your AppIcon
2. Change the type to **Solid Image Stack** (if available)
3. Add your icon to the **Front** layer
4. Optionally add depth effects to **Middle** and **Back** layers

For StarDate, you can use:
- **Front**: The full starfield warp icon
- **Middle**: Slightly blurred version for depth
- **Back**: Dark background only

## Color Specifications

The icon uses these colors:
- **Background**: Dark blue/purple gradient (`#0a0a1a` to `#2a2a5a`)
- **Warp Lines**: Cyan (`#00ffff`)
- **Stars**: Cyan to white gradient
- **Center Point**: Bright cyan (`#00ffff`)

## Tips

1. **Test on Device**: Always preview the icon on an actual Vision Pro or simulator
2. **High Resolution**: Use at least 1024x1024 for best quality
3. **Contrast**: Ensure the icon is visible against various backgrounds
4. **Simplicity**: Keep details clear even at small sizes
5. **Brand Consistency**: The turquoise/cyan matches the app's button color

## Troubleshooting

**Icon appears blurry:**
- Ensure you're using 1024x1024 source image
- Check that Xcode isn't downscaling
- Verify the image format is PNG (not JPEG)

**Icon doesn't appear:**
- Clean build folder (`⌘⇧K`)
- Delete derived data
- Rebuild the project

**Colors look different:**
- Check color profile (sRGB recommended)
- Verify transparency is handled correctly
- Test on actual device vs simulator
