# StarDate - Vision Pro Diary App

A beautiful Vision Pro app that allows you to keep a diary by speaking. The app transcribes your voice, analyzes the content using Apple's Foundation models, and provides summaries, jokes, and advice.

## Features

- 🎤 Voice recording with real-time transcription
- ⭐ Beautiful starfield background
- 💎 Glowing turquoise button interface
- 📝 Automatic transcription using Speech framework
- 🤖 AI-powered content analysis using Natural Language framework
- 📊 Summary generation
- 😄 Contextual joke generation
- 💡 Personalized advice based on sentiment analysis
- 💾 Persistent storage of diary entries with:
  - StarDate (UTC ISO timestamp)
  - Text transcript
  - Raw audio recording

## Setup Instructions

1. Open the project in Xcode
2. Ensure you're targeting visionOS
3. Add the Info.plist entries to your project's Info.plist (or configure in project settings):
   - `NSSpeechRecognitionUsageDescription`
   - `NSMicrophoneUsageDescription`
   - `NSDocumentsFolderUsageDescription`
4. Build and run on Vision Pro simulator or device

## Project Structure

- `StarDateApp.swift` - App entry point
- `Models/DiaryEntry.swift` - Data model for diary entries
- `Views/` - All SwiftUI views
  - `ContentView.swift` - Main screen with starfield and button
  - `StarfieldView.swift` - Animated starfield background
  - `RecordingView.swift` - Recording and transcription interface
  - `AnalysisResultView.swift` - Display analysis results
- `Services/` - Core functionality
  - `AudioRecorder.swift` - Handles audio recording and speech recognition
  - `ContentAnalyzer.swift` - Analyzes content using Natural Language framework
  - `DiaryStorageManager.swift` - Manages diary entry storage

## Requirements

- visionOS 1.0+
- Xcode 15.0+
- Swift 5.9+

## Usage

1. Launch the app to see the starfield with a glowing turquoise button
2. Tap the button to start a new diary entry
3. Speak your thoughts - the app will transcribe in real-time
4. Tap stop when finished
5. Tap "Analyze" to get a summary, joke, and advice
6. Tap "Save" to store your entry

## Technical Details

- Uses `AVAudioEngine` and `AVAudioRecorder` for audio capture
- Uses `SFSpeechRecognizer` for speech-to-text transcription
- Uses `NaturalLanguage` framework for content analysis
- Stores entries in UserDefaults (metadata) and Documents directory (audio files)
- All timestamps are in UTC ISO 8601 format
# stardate
