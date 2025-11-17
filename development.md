# StarDate - Development Guide

This guide covers how to build and run StarDate in the Xcode simulator and deploy it to a real Vision Pro device.

## Prerequisites

- **macOS**: macOS 14.0 (Sonoma) or later
- **Xcode**: Xcode 15.0 or later (with visionOS SDK)
- **Apple Developer Account**: Required for device deployment (free account works for development)
- **Vision Pro Device** (optional, for physical device testing)

## Setting Up the Project

### 1. Create New Xcode Project

1. Open **Xcode**
2. Select **File → New → Project** (or press `⌘⇧N`)
3. Choose **visionOS** platform
4. Select **App** template
5. Click **Next**
6. Configure project:
   - **Product Name**: `StarDate`
   - **Team**: Select your development team (or "None" for simulator-only)
   - **Organization Identifier**: `com.yourname` (or your preferred identifier)
   - **Interface**: `SwiftUI`
   - **Language**: `Swift`
   - **Storage**: `None` (we handle our own storage)
7. Choose a location to save the project
8. Click **Create**

### 2. Add Source Files

1. In Xcode's Project Navigator, right-click on the `StarDate` folder
2. Select **Add Files to "StarDate"...**
3. Navigate to the StarDate source directory
4. Select all files and folders:
   - `StarDateApp.swift` (replace the default `App.swift` if it exists)
   - `Models/` folder
   - `Views/` folder
   - `Services/` folder
5. Ensure **"Copy items if needed"** is checked
6. Ensure **"Create groups"** is selected
7. Click **Add**

### 3. Configure Info.plist

1. In Project Navigator, select your project (top item)
2. Select the **StarDate** target
3. Go to the **Info** tab
4. Add the following keys (click the `+` button to add each):

   **NSSpeechRecognitionUsageDescription**
   - Type: `String`
   - Value: `StarDate needs access to speech recognition to transcribe your diary entries.`

   **NSMicrophoneUsageDescription**
   - Type: `String`
   - Value: `StarDate needs access to your microphone to record your diary entries.`

   **NSDocumentsFolderUsageDescription**
   - Type: `String`
   - Value: `StarDate needs access to save your diary entries and audio recordings.`

   Alternatively, if you have an `Info.plist` file in your project:
   - Right-click `Info.plist` → **Open As → Source Code**
   - Add the keys from the provided `Info.plist` file

### 4. Configure Build Settings

1. Select the **StarDate** target
2. Go to **Build Settings** tab
3. Search for **"iOS Deployment Target"** (or "visionOS Deployment Target")
4. Set minimum deployment target to **visionOS 1.0** or later
5. Ensure **Swift Language Version** is set to **Swift 5** or later

## Running in Xcode Simulator

### 1. Select Simulator

1. In Xcode's toolbar, click the device selector (next to the Run button)
2. Under **visionOS**, select a simulator:
   - **Apple Vision Pro** (recommended)
   - Any available visionOS simulator

### 2. Build and Run

1. Click the **Run** button (▶️) or press `⌘R`
2. Wait for Xcode to build the project
3. The simulator will launch automatically
4. The app will install and launch in the simulator

### 3. Grant Permissions

When the app launches for the first time:
1. **Microphone Permission**: Click **"Allow"** when prompted
2. **Speech Recognition Permission**: Click **"Allow"** when prompted

### 4. Testing in Simulator

- The simulator supports microphone input (uses your Mac's microphone)
- Speech recognition works in the simulator
- All features should function normally

### Troubleshooting Simulator Issues

**Issue**: Simulator doesn't launch
- **Solution**: Go to **Xcode → Settings → Platforms** and ensure visionOS simulator is installed

**Issue**: Microphone not working
- **Solution**: Check **System Settings → Privacy & Security → Microphone** and ensure Xcode/Simulator has access

**Issue**: Speech recognition not working
- **Solution**: Ensure you're connected to the internet (speech recognition may require network access)

## Deploying to Real Vision Pro Device

### 1. Connect Your Vision Pro

1. Put on your Vision Pro
2. Connect it to your Mac via USB-C cable
3. On your Vision Pro, you may need to:
   - Go to **Settings → Developer Mode**
   - Enable **Developer Mode** (if not already enabled)
   - Restart the device if prompted

### 2. Configure Signing & Capabilities

1. In Xcode, select your project in Project Navigator
2. Select the **StarDate** target
3. Go to **Signing & Capabilities** tab
4. Under **Signing**:
   - Check **"Automatically manage signing"**
   - Select your **Team** from the dropdown
   - If you don't have a team:
     - Click **"Add Account..."**
     - Sign in with your Apple ID
     - Accept the terms if prompted
     - Select your account from the Team dropdown

### 3. Select Your Device

1. In Xcode's toolbar, click the device selector
2. Under **visionOS Device**, select your connected **Apple Vision Pro**
3. If your device doesn't appear:
   - Ensure it's connected via USB-C
   - Check that Developer Mode is enabled on the device
   - Try unplugging and reconnecting the cable
   - Restart Xcode

### 4. Build and Deploy

1. Click the **Run** button (▶️) or press `⌘R`
2. Xcode will:
   - Build the app
   - Sign it with your development certificate
   - Install it on your Vision Pro
   - Launch the app

### 5. Trust Developer Certificate (First Time Only)

If this is your first time deploying to this device:
1. On your Vision Pro, go to **Settings → General → VPN & Device Management**
2. Find your developer certificate
3. Tap it and select **"Trust [Your Name]"**
4. Confirm by tapping **"Trust"**

### 6. Grant Permissions on Device

When the app launches for the first time:
1. **Microphone Permission**: Tap **"Allow"** when prompted
2. **Speech Recognition Permission**: Tap **"Allow"** when prompted

### Troubleshooting Device Deployment

**Issue**: "No devices found"
- **Solution**:
  - Ensure USB-C cable is properly connected
  - Enable Developer Mode on Vision Pro
  - Restart both Mac and Vision Pro
  - Check USB-C cable (try a different cable)

**Issue**: "Signing for StarDate requires a development team"
- **Solution**:
  - Add your Apple ID in Xcode Settings → Accounts
  - Select your team in Signing & Capabilities
  - Or create a free Apple Developer account at developer.apple.com

**Issue**: "Failed to register bundle identifier"
- **Solution**:
  - Change the Bundle Identifier in Signing & Capabilities to something unique
  - Format: `com.yourname.stardate` (use your own name/company)

**Issue**: App crashes on launch
- **Solution**:
  - Check Console in Xcode for error messages
  - Ensure all permissions are granted
  - Verify Info.plist keys are correctly configured
  - Check that all source files are added to the target

**Issue**: Microphone/Speech recognition not working
- **Solution**:
  - Check Vision Pro Settings → Privacy & Security → Microphone
  - Ensure StarDate has microphone access
  - Check internet connection (speech recognition may need network)

## Development Tips

### Debugging

- Use **Console** in Xcode to view logs: **View → Debug Area → Activate Console** (or `⌘⇧C`)
- Set breakpoints by clicking in the gutter next to line numbers
- Use **LLDB** debugger for advanced debugging

### Testing Audio Recording

- Test with short recordings first
- Check Documents directory in simulator/device for saved audio files
- Use Xcode's **Window → Devices and Simulators** to access device filesystem

### Performance

- Monitor memory usage in Xcode's Debug Navigator
- Use Instruments for detailed performance analysis: **Product → Profile** (⌘I)

### Code Signing

- Development builds expire after 7 days (free account) or 1 year (paid account)
- Rebuild and redeploy before expiration
- For distribution, configure App Store or TestFlight distribution

## Building for Distribution

### Archive Build

1. Select **Any visionOS Device** or **Generic iOS Device** from device selector
2. Go to **Product → Archive**
3. Wait for archive to complete
4. Organizer window will open
5. Click **Distribute App**
6. Follow the distribution wizard

### TestFlight (Beta Testing)

1. Archive the app (see above)
2. In Organizer, select your archive
3. Click **Distribute App**
4. Choose **TestFlight & App Store**
5. Follow the upload process
6. Configure in App Store Connect

## Additional Resources

- [Apple Vision Pro Development Documentation](https://developer.apple.com/documentation/visionos)
- [Xcode Documentation](https://developer.apple.com/documentation/xcode)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Speech Framework Documentation](https://developer.apple.com/documentation/speech)

## Quick Reference Commands

- **Build**: `⌘B`
- **Run**: `⌘R`
- **Stop**: `⌘.`
- **Clean Build Folder**: `⌘⇧K`
- **Show/Hide Debug Area**: `⌘⇧Y`
- **Show/Hide Navigator**: `⌘0`
- **Show/Hide Utilities**: `⌘⌥0`
