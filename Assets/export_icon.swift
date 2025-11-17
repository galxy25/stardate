#!/usr/bin/env swift
//
//  export_icon.swift
//  StarDate Icon Exporter
//
//  Run this script to export the app icon as PNG
//  Usage: swift export_icon.swift
//

import SwiftUI
import AppKit

// Note: This is a template script. You'll need to adapt it based on your setup.
// For a full implementation, you'd need to create a macOS app or use a different approach.

print("""
To export the app icon:

Option 1: Use Xcode Preview
1. Open AppIconView.swift in Xcode
2. Click the Preview button
3. Right-click and export or take a screenshot

Option 2: Use the SVG file
1. Open AppIcon.svg in a vector editor
2. Export as PNG at 1024x1024

Option 3: Use online SVG to PNG converter
1. Upload AppIcon.svg to an online converter
2. Set size to 1024x1024
3. Download the PNG

The SVG file is located at: Assets/AppIcon.svg
""")
