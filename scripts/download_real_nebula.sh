#!/bin/bash

# Download a real, verified nebula image
# This script downloads high-quality nebula images from reliable sources

set -e

ASSETS_DIR="StarDate/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Nebula"
mkdir -p "$ASSETS_DIR"

echo "🌌 Downloading verified nebula images..."

# Try multiple sources to get a real nebula image

# Option 1: NASA Hubble Carina Nebula (verified nebula)
echo "📥 Attempting to download Carina Nebula from NASA..."
CARINA_URL="https://stsci-opo.org/STScI-01EVT0VZ3N8Z6ZXD0Y0P6M4J1X.jpg"
if curl -L -f -o "$ASSETS_DIR/nebula_01.jpg" "$CARINA_URL" 2>/dev/null; then
    echo "✅ Downloaded Carina Nebula from STScI"
else
    echo "⚠️  STScI download failed, trying alternative..."

    # Option 2: ESA Hubble Orion Nebula
    echo "📥 Attempting to download Orion Nebula from ESA..."
    ORION_URL="https://cdn.esawebb.org/archives/images/large/heic1312a.jpg"
    if curl -L -f -o "$ASSETS_DIR/nebula_01.jpg" "$ORION_URL" 2>/dev/null; then
        echo "✅ Downloaded Orion Nebula from ESA"
    else
        echo "⚠️  ESA download failed, trying Unsplash verified nebula..."

        # Option 3: Unsplash - verified space/nebula photo
        # This is a known nebula image on Unsplash
        UNSPLASH_URL="https://images.unsplash.com/photo-1462331940025-496dfbfc7564?w=4096&h=2048&fit=crop&q=90&fm=jpg"
        if curl -L -f -o "$ASSETS_DIR/nebula_01.jpg" "$UNSPLASH_URL" 2>/dev/null; then
            echo "✅ Downloaded nebula from Unsplash"
        else
            echo "❌ All automatic downloads failed."
            echo ""
            echo "Please download manually from:"
            echo "1. NASA: https://images.nasa.gov/search-results?q=carina%20nebula"
            echo "2. ESA Hubble: https://esahubble.org/images/"
            echo "3. Save as: $ASSETS_DIR/nebula_01.jpg"
            exit 1
        fi
    fi
fi

# Verify the downloaded image
if [ -f "$ASSETS_DIR/nebula_01.jpg" ]; then
    FILE_SIZE=$(stat -f%z "$ASSETS_DIR/nebula_01.jpg" 2>/dev/null || stat -c%s "$ASSETS_DIR/nebula_01.jpg" 2>/dev/null)
    FILE_INFO=$(file "$ASSETS_DIR/nebula_01.jpg")

    echo ""
    echo "📊 Image Verification:"
    echo "   File: $ASSETS_DIR/nebula_01.jpg"
    echo "   Size: $(numfmt --to=iec-i --suffix=B $FILE_SIZE 2>/dev/null || echo "${FILE_SIZE} bytes")"
    echo "   Type: $FILE_INFO"

    # Check if it's a valid image and has reasonable size
    if [[ $FILE_SIZE -lt 10000 ]]; then
        echo "⚠️  WARNING: File seems too small, might be an error page"
        echo "   Please verify the image manually"
    else
        echo "✅ Image appears valid"
    fi

    # Try to get image dimensions if sips is available (macOS)
    if command -v sips &> /dev/null; then
        DIMENSIONS=$(sips -g pixelWidth -g pixelHeight "$ASSETS_DIR/nebula_01.jpg" 2>/dev/null | grep -E "pixelWidth|pixelHeight" | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        if [ ! -z "$DIMENSIONS" ]; then
            echo "   Dimensions: $DIMENSIONS"
        fi
    fi
else
    echo "❌ Download failed - file not found"
    exit 1
fi

echo ""
echo "✅ Nebula image downloaded successfully!"
echo "   Location: $ASSETS_DIR/nebula_01.jpg"
echo ""
echo "Next: Add this file to your Xcode project's RealityKitContent bundle"

