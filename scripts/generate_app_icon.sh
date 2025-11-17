#!/bin/bash

# Generate 512x512 app icon from SVG for visionOS
# This script creates the proper sized icon for the Back layer

set -e

ASSETS_DIR="StarDate/StarDate/Assets.xcassets/AppIcon.solidimagestack"
BACK_LAYER_DIR="$ASSETS_DIR/Back.solidimagestacklayer/Content.imageset"
SVG_FILE="Assets/AppIcon.svg"

echo "🎨 Generating 512x512 app icon for visionOS..."

# Check if we have the SVG
if [ ! -f "$SVG_FILE" ]; then
    echo "❌ SVG file not found: $SVG_FILE"
    echo "Creating a simple 512x512 icon instead..."

    # Create a simple 512x512 PNG using sips (macOS built-in)
    # First, let's create a solid color background
    if command -v sips &> /dev/null; then
        # Create a temporary 512x512 image
        sips --setProperty format png --setProperty formatOptions normal \
             --resampleHeightWidthMax 512 \
             "$ASSETS_DIR/Front.solidimagestacklayer/Content.imageset/iPad App Icon iOS 5,6@2x.png" \
             --out "$BACK_LAYER_DIR/icon_512x512.png" 2>/dev/null || {
            echo "Creating new 512x512 icon..."
            # Use Python or another method to create the icon
            python3 << 'PYTHON'
from PIL import Image, ImageDraw
import os

# Create 512x512 image
img = Image.new('RGB', (512, 512), color='#0a0a1a')
draw = ImageDraw.Draw(img)

# Draw a simple starfield pattern
import random
random.seed(42)
for _ in range(100):
    x = random.randint(0, 512)
    y = random.randint(0, 512)
    size = random.randint(1, 3)
    draw.ellipse([x-size, y-size, x+size, y+size], fill='white', outline='white')

# Draw center warp point
center = 256
draw.ellipse([center-20, center-20, center+20, center+20], fill='#00ffff', outline='#00ffff')
draw.ellipse([center-30, center-30, center+30, center+30], fill='#00ffff', outline='#00ffff')
draw.ellipse([center-30, center-30, center+30, center+30], fill=None, outline='#00ffff', width=2)

# Save
output_path = 'StarDate/StarDate/Assets.xcassets/AppIcon.solidimagestack/Back.solidimagestacklayer/Content.imageset/icon_512x512.png'
os.makedirs(os.path.dirname(output_path), exist_ok=True)
img.save(output_path)
print(f"Created {output_path}")
PYTHON
        }
    fi
else
    echo "📐 Converting SVG to 512x512 PNG..."
    # If we have rsvg-convert or another SVG converter
    if command -v rsvg-convert &> /dev/null; then
        rsvg-convert -w 512 -h 512 "$SVG_FILE" -o "$BACK_LAYER_DIR/icon_512x512.png"
    elif command -v convert &> /dev/null; then
        convert -background none -resize 512x512 "$SVG_FILE" "$BACK_LAYER_DIR/icon_512x512.png"
    else
        echo "⚠️  No SVG converter found. Using resize method..."
        # Try to resize existing icon
        if command -v sips &> /dev/null; then
            sips --resampleHeightWidth 512 512 \
                 "$ASSETS_DIR/Front.solidimagestacklayer/Content.imageset/iPad App Icon iOS 5,6@2x.png" \
                 --out "$BACK_LAYER_DIR/icon_512x512.png"
        fi
    fi
fi

# Update Contents.json to use the new 512x512 image
if [ -f "$BACK_LAYER_DIR/icon_512x512.png" ]; then
    cat > "$BACK_LAYER_DIR/Contents.json" << 'EOF'
{
  "images" : [
    {
      "filename" : "icon_512x512.png",
      "idiom" : "vision",
      "scale" : "1x",
      "size" : "512x512"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF
    echo "✅ Updated Back layer Contents.json"
    echo "✅ Created 512x512 icon: $BACK_LAYER_DIR/icon_512x512.png"
else
    echo "⚠️  Could not create 512x512 icon automatically"
    echo "Please manually create a 512x512 PNG and place it at:"
    echo "  $BACK_LAYER_DIR/icon_512x512.png"
    echo ""
    echo "Then update Contents.json to reference it."
fi

