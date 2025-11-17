#!/bin/bash

# Download Nebula Assets for StarDate
# This script downloads free nebula images/textures for use in the immersive space

set -e

# Create assets directory
ASSETS_DIR="StarDate/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Nebula"
mkdir -p "$ASSETS_DIR"

echo "🌌 Downloading nebula assets for StarDate..."

# Note: These are example URLs. You'll need to replace them with actual free-to-use nebula assets.
# Here are some recommended sources:
# - NASA Image and Video Library (free, public domain)
# - Unsplash (free, attribution required)
# - Pixabay (free, no attribution required)
# - Poly Haven (CC0, free)

# Example: Download from NASA (replace with actual URLs)
# NASA has many free space images, but we'll use placeholder URLs here
# You should visit https://images.nasa.gov/ and search for "nebula"

echo "📝 Please download nebula assets manually from these sources:"
echo ""
echo "1. NASA Image and Video Library:"
echo "   https://images.nasa.gov/"
echo "   Search for: 'nebula', 'orion nebula', 'carina nebula'"
echo ""
echo "2. Unsplash (Free, requires attribution):"
echo "   https://unsplash.com/s/photos/nebula"
echo ""
echo "3. Pixabay (Free, no attribution):"
echo "   https://pixabay.com/images/search/nebula/"
echo ""
echo "4. Poly Haven HDRI (360° panoramas, CC0):"
echo "   https://polyhaven.com/hdris?q=space"
echo ""
echo "Recommended formats:"
echo "  - 360° equirectangular panoramas (for sky domes)"
echo "  - High resolution (4096x2048 or higher)"
echo "  - Formats: JPG, PNG, or HDR"
echo ""
echo "After downloading, place files in:"
echo "  $ASSETS_DIR"
echo ""

# Create a sample download using curl (if you have direct URLs)
# Uncomment and modify these when you have actual URLs:

# echo "Downloading nebula texture 1..."
# curl -L -o "$ASSETS_DIR/nebula_01.jpg" "YOUR_URL_HERE"

# echo "Downloading nebula texture 2..."
# curl -L -o "$ASSETS_DIR/nebula_02.jpg" "YOUR_URL_HERE"

# For now, let's create a placeholder script that downloads from a known free source
# Using NASA's API (requires API key) or direct image links

echo "✅ Asset directory created at: $ASSETS_DIR"
echo ""
echo "Next steps:"
echo "1. Download nebula images from the sources above"
echo "2. Place them in the $ASSETS_DIR directory"
echo "3. Run the conversion script to create USDZ files if needed"
echo "4. Update ImmersiveView.swift to use the new assets"
