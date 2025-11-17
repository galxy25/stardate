# Nebula Assets Guide

This guide explains how to download and use nebula images for the StarDate immersive space.

## Quick Start

1. **Download nebula images** from the sources below
2. **Place them** in: `StarDate/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Nebula/`
3. **Name them**: `nebula_01.jpg`, `nebula_02.jpg`, etc.
4. **Build and run** - the app will automatically load them

## Recommended Sources

### 1. NASA Image and Video Library (Public Domain - Free)

**Best for**: High-quality, scientifically accurate nebula images

- **Website**: https://images.nasa.gov/
- **Search terms**: "nebula", "Orion Nebula", "Carina Nebula", "Eagle Nebula"
- **License**: Public Domain (free to use, no attribution required)
- **Formats**: JPG, PNG, TIFF
- **Recommended**: Download highest resolution available

**Popular NASA Nebula Images**:
- Orion Nebula (M42)
- Carina Nebula
- Eagle Nebula (Pillars of Creation)
- Helix Nebula
- Crab Nebula

### 2. Unsplash (Free with Attribution)

**Best for**: Artistic, high-quality space photography

- **Website**: https://unsplash.com/s/photos/nebula
- **License**: Free to use (attribution appreciated but not required)
- **Formats**: JPG
- **Resolution**: Very high (often 4000px+)

### 3. Pixabay (Free, No Attribution)

**Best for**: Quick downloads, no attribution needed

- **Website**: https://pixabay.com/images/search/nebula/
- **License**: Free for commercial use, no attribution required
- **Formats**: JPG, PNG
- **Resolution**: Various sizes available

### 4. Poly Haven (CC0 - Free)

**Best for**: 360° HDRI panoramas (perfect for immersive spaces!)

- **Website**: https://polyhaven.com/hdris?q=space
- **License**: CC0 (completely free)
- **Formats**: HDR, EXR, JPG
- **Special**: 360° equirectangular panoramas ideal for sky domes

**Recommended HDRI**:
- Space environments
- Nebula panoramas
- Starfield backgrounds

### 5. Sketchfab (Some Free Models)

**Best for**: 3D nebula models and 360° panoramas

- **Website**: https://sketchfab.com/3d-models?q=nebula
- **Filter**: Free models only
- **Formats**: USDZ, GLB, OBJ
- **Note**: Check individual licenses

## Image Requirements

### For Sky Dome (360° Background)

**Ideal specifications**:
- **Format**: Equirectangular panorama (360°)
- **Resolution**: 4096x2048 or higher (8192x4096 is ideal)
- **Aspect Ratio**: 2:1 (width:height)
- **Format**: JPG, PNG, or HDR

### For Static Backgrounds

**Minimum specifications**:
- **Resolution**: 2048x2048 or higher
- **Format**: JPG or PNG
- **Aspect Ratio**: Square or 16:9

## Download Instructions

### Method 1: Manual Download

1. Visit one of the sources above
2. Search for "nebula" or specific nebula names
3. Download the highest resolution available
4. Rename to `nebula_01.jpg`, `nebula_02.jpg`, etc.
5. Place in: `StarDate/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Nebula/`

### Method 2: Using Download Scripts

```bash
# Make scripts executable
chmod +x scripts/download_nebula_assets.sh
chmod +x scripts/download_nasa_nebula.sh

# Run the download script
./scripts/download_nebula_assets.sh
```

**Note**: The scripts provide instructions. You'll need to manually download from the websites as direct download URLs vary.

### Method 3: Using curl (if you have direct URLs)

```bash
# Example (replace with actual URLs)
cd StarDate/Packages/RealityKitContent/Sources/RealityKitContent/RealityKitContent.rkassets/Nebula
curl -L -o nebula_01.jpg "YOUR_NASA_IMAGE_URL_HERE"
curl -L -o nebula_02.jpg "YOUR_UNSPLASH_IMAGE_URL_HERE"
```

## Adding Assets to Xcode

1. **Open Xcode**
2. **Navigate** to `RealityKitContent` package
3. **Right-click** on `RealityKitContent.rkassets`
4. **Select** "Add Files to RealityKitContent..."
5. **Choose** your nebula image files
6. **Ensure** "Copy items if needed" is checked
7. **Click** "Add"

## Using the Assets

The `ImmersiveView.swift` automatically loads nebula textures:

1. First tries to load from RealityKitContent bundle
2. Falls back to main app bundle
3. Falls back to Documents directory (for runtime downloads)
4. Falls back to procedural nebula material if none found

## Converting 360° Panoramas

If you download 360° HDRI panoramas:

1. **Option A**: Use Reality Composer Pro
   - Open Reality Composer Pro
   - Create a new scene
   - Add a sky dome
   - Apply your nebula texture
   - Export as USDZ

2. **Option B**: Use the code (already implemented)
   - The `ImmersiveView` creates a sky dome programmatically
   - Just place your 360° image in the Nebula folder
   - Name it `nebula_01.jpg` (or update the code to use your filename)

## Performance Tips

- **Optimize images**: Use JPG for smaller file sizes
- **Resolution**: 4096x2048 is a good balance of quality and performance
- **Multiple nebulas**: The app can cycle through different nebulas
- **Caching**: Textures are cached after first load

## Troubleshooting

**Images not loading?**
- Check file names match exactly (case-sensitive)
- Ensure images are in the correct directory
- Verify images are added to the Xcode target
- Check file formats are supported (JPG, PNG, HDR)

**Performance issues?**
- Reduce image resolution
- Use JPG instead of PNG
- Limit number of nebula textures

**360° images look distorted?**
- Ensure images are equirectangular format
- Check aspect ratio is 2:1 (width:height)
- Verify image is not mirrored or rotated

## Example Download Links

Here are some direct links to get you started (verify licenses before commercial use):

**NASA**:
- https://images.nasa.gov/search-results?q=nebula

**Unsplash**:
- https://unsplash.com/s/photos/nebula

**Pixabay**:
- https://pixabay.com/images/search/nebula/

**Poly Haven**:
- https://polyhaven.com/hdris?q=space

## Legal Notes

- **NASA images**: Public domain, free to use
- **Unsplash**: Free to use (attribution appreciated)
- **Pixabay**: Free for commercial use, no attribution
- **Poly Haven**: CC0, completely free
- **Always verify**: Check individual image licenses before commercial use
