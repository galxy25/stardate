# App Icon Setup for visionOS

## What Was Created

A complete **Solid Image Stack** icon structure for visionOS has been set up in:
```
StarDate/StarDate/Assets.xcassets/AppIcon.solidimagestack/
```

### Structure
- **Front Layer**: Bright cyan background with "FRONT" label (2048x2048 PNG)
- **Middle Layer**: Medium blue background with "MIDDLE" label (2048x2048 PNG)
- **Back Layer**: Dark purple background with "BACK" label (2048x2048 PNG)

These are **placeholder icons** designed to be easily recognizable so you can verify they're being used correctly.

## How to Verify Icons Are Working

1. **Open Xcode** and open the StarDate project
2. **Clean Build Folder**: Press `⌘⇧K` (Cmd+Shift+K)
3. **Build and Run** the app on the Vision Pro simulator or device
4. **Check the Home Screen**: You should see the app icon with:
   - A bright cyan front layer (most visible)
   - A blue middle layer (creates depth)
   - A dark purple back layer (background)

The icon should appear as a 3D circular object with depth, showing all three layers stacked.

## Next Steps: Replace with Final Design

Once you've verified the placeholder icons are working:

1. **Export your final icon design** from `Assets/AppIcon.svg`:
   - Front layer: Full starfield warp design (1024x1024 or 2048x2048 PNG)
   - Middle layer: Slightly blurred version for depth effect (optional)
   - Back layer: Dark background only

2. **Replace the placeholder icons**:
   - Replace `Front.solidimagestacklayer/Content.imageset/icon.png`
   - Replace `Middle.solidimagestacklayer/Content.imageset/icon.png` (optional)
   - Replace `Back.solidimagestacklayer/Content.imageset/icon.png`

3. **Rebuild** the app to see your final icon

## Icon Generation Script

A script is available to regenerate placeholder icons if needed:
```bash
swift scripts/generate_placeholder_icons.swift
```

## Troubleshooting

**Icon still appears blank:**
- Make sure you've cleaned the build folder (`⌘⇧K`)
- Delete Derived Data: Xcode → Settings → Locations → Derived Data → Delete
- Rebuild the project completely

**Icon appears but wrong colors:**
- Verify the PNG files are in the correct locations
- Check that Contents.json files reference the correct filenames
- Ensure images are PNG format (not JPEG)

**Xcode doesn't recognize the icon:**
- Verify the asset catalog name matches: `AppIcon` (as set in project settings)
- Check that `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` in build settings
