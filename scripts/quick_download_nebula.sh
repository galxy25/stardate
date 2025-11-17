#!/bin/bash

# Quick script to download a sample nebula image for testing
# This downloads a free nebula image from Unsplash (free to use)

set -e

ASSETS_DIR="StarDate/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Nebula"
mkdir -p "$ASSETS_DIR"

echo "🌌 Downloading sample nebula image..."

# Download a sample nebula image from Unsplash Source API
# Note: This is a placeholder. Replace with actual image URL or use Unsplash Source API
# Unsplash Source: https://source.unsplash.com/

# Example: Download a space/nebula image (this is a random image, replace with specific one)
echo "📥 Downloading from Unsplash..."

# Using Unsplash Source API (random space image)
# Replace this URL with a specific nebula image URL from Unsplash
curl -L -o "$ASSETS_DIR/nebula_01.jpg" "https://images.unsplash.com/photo-1446776653964-20c1d3a81b06?w=4096&h=2048&fit=crop" || {
    echo "⚠️  Direct download failed. Please download manually:"
    echo ""
    echo "1. Visit: https://unsplash.com/s/photos/nebula"
    echo "2. Choose an image"
    echo "3. Download the highest resolution"
    echo "4. Save as: $ASSETS_DIR/nebula_01.jpg"
    echo ""
    echo "Or use NASA images:"
    echo "1. Visit: https://images.nasa.gov/search-results?q=nebula"
    echo "2. Download an image"
    echo "3. Save as: $ASSETS_DIR/nebula_01.jpg"
    exit 1
}

if [ -f "$ASSETS_DIR/nebula_01.jpg" ]; then
    echo "✅ Successfully downloaded nebula image!"
    echo "   Location: $ASSETS_DIR/nebula_01.jpg"
    echo ""
    echo "Next steps:"
    echo "1. Build and run the app"
    echo "2. Click 'Enter Nebula' button"
    echo "3. The nebula should appear in the immersive space"
else
    echo "❌ Download failed. Please download manually (see instructions above)."
    exit 1
fi
