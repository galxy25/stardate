#!/bin/bash

# Download Nebula Images from NASA
# NASA images are in the public domain and free to use

set -e

ASSETS_DIR="StarDate/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Nebula"
mkdir -p "$ASSETS_DIR"

echo "🌌 Downloading nebula images from NASA..."

# NASA Image and Video Library API
# Note: These are example image IDs. Visit https://images.nasa.gov/ to find more
# You can search for specific nebula images and get their NASA IDs

# Example NASA image URLs (these are placeholders - you'll need to find actual ones)
# Format: https://images-assets.nasa.gov/image/[NASA_ID]/[NASA_ID]~orig.jpg

# Some popular nebula images from NASA:
# - Orion Nebula
# - Carina Nebula
# - Eagle Nebula
# - Helix Nebula

echo "📥 Attempting to download sample nebula images..."

# Note: Replace these with actual NASA image IDs from images.nasa.gov
# For now, we'll create a script that you can customize

cat > "$ASSETS_DIR/README.md" << 'EOF'
# Nebula Assets

## How to Download NASA Nebula Images

1. Visit https://images.nasa.gov/
2. Search for "nebula" or specific nebulas like:
   - "Orion Nebula"
   - "Carina Nebula"
   - "Eagle Nebula"
   - "Helix Nebula"
3. Click on an image you like
4. Click "Download" and choose the highest resolution
5. Save the image to this directory

## Recommended Images

For 360° immersive backgrounds, look for:
- Equirectangular panoramas
- 360° space images
- HDRI space environments

## Converting to USDZ

If you have 360° panoramas, you can:
1. Use Reality Composer Pro to create a sky dome
2. Apply the nebula texture to the sky dome material
3. Export as USDZ

Or use the provided Swift code to load images dynamically.
EOF

echo "✅ Created README in assets directory"
echo ""
echo "Manual download instructions saved to: $ASSETS_DIR/README.md"
echo ""
echo "Quick download links (open in browser):"
echo "  NASA Images: https://images.nasa.gov/search-results?q=nebula"
echo "  Unsplash: https://unsplash.com/s/photos/nebula"
echo "  Pixabay: https://pixabay.com/images/search/nebula/"
