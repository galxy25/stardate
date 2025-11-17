# StarDate - Xcode Project Setup

## Creating the Xcode Project

1. Open Xcode
2. Create a new project:
   - Choose "App" under visionOS
   - Product Name: `StarDate`
   - Interface: `SwiftUI`
   - Language: `Swift`
   - Storage: `None` (we'll use our own storage)

## Adding Files to the Project

1. In Xcode, right-click on the project navigator
2. Select "Add Files to StarDate..."
3. Add all the folders and files:
   - `StarDateApp.swift` (replace the default App file)
   - `Models/` folder
   - `Views/` folder
   - `Services/` folder
   - `Info.plist` (or add the keys to your existing Info.plist)

## Configuring Info.plist

Add these keys to your `Info.plist` (or configure in project settings under "Info" tab):

- `NSSpeechRecognitionUsageDescription`: "StarDate needs access to speech recognition to transcribe your diary entries."
- `NSMicrophoneUsageDescription`: "StarDate needs access to your microphone to record your diary entries."
- `NSDocumentsFolderUsageDescription`: "StarDate needs access to save your diary entries and audio recordings."

## Project Settings

1. Go to your target's "Signing & Capabilities"
2. Ensure you have:
   - Speech Recognition capability (if available)
   - Microphone usage enabled

## Build and Run

1. Select a Vision Pro simulator or device
2. Build and run (⌘R)
3. Grant permissions when prompted

## Notes

- The app uses `AVAudioEngine` for real-time audio capture
- Speech recognition uses `SFSpeechRecognizer`
- Content analysis uses `NaturalLanguage` framework
- Audio files are saved in the app's Documents directory
- Entry metadata is stored in UserDefaults
