//
//  AudioRecorder.swift
//  StarDate
//

import Foundation
import AVFoundation
import Speech
import Combine

class AudioRecorder: NSObject, ObservableObject {
    @Published var transcript = ""
    @Published var isRecording = false

    private var audioEngine: AVAudioEngine?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    private(set) var audioFileURL: URL?
    private var audioRecorder: AVAudioRecorder?

    override init() {
        super.init()
        requestAuthorization()
    }

    private func requestAuthorization() {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                // Handle authorization status if needed
            }
        }

        // Use the new visionOS API for requesting record permission
        if #available(visionOS 1.0, *) {
            AVAudioApplication.requestRecordPermission { granted in
                DispatchQueue.main.async {
                    // Handle permission status if needed
                }
            }
        } else {
            // Fallback for older versions (though visionOS 1.0 is minimum)
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                DispatchQueue.main.async {
                    // Handle permission status if needed
                }
            }
        }
    }

    func startRecording() {
        print("🎤 startRecording() called")
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            print("❌ Speech recognizer not available")
            return
        }
        print("✅ Speech recognizer is available")

        // Stop any existing recording synchronously (but don't wait for async cleanup)
        if let engine = audioEngine {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
        }
        recognitionRequest?.endAudio()
        recognitionTask?.cancel()
        audioRecorder?.stop()

        // Clean up references immediately
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        audioRecorder = nil

        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // First deactivate any existing session
            try? audioSession.setActive(false)

            // Set category and activate
            try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            print("✅ Audio session configured and activated")
        } catch {
            print("❌ Failed to setup audio session: \(error)")
            print("   Error details: \(error.localizedDescription)")
            return
        }

        // Setup audio engine
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else { return }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Setup recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        recognitionRequest.shouldReportPartialResults = true

        // Setup audio file recording
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let newAudioFileURL = documentsPath.appendingPathComponent("recording_\(UUID().uuidString).m4a")
        self.audioFileURL = newAudioFileURL

        do {
            // Create AVAudioRecorder with proper settings for M4A/AAC format
            audioRecorder = try AVAudioRecorder(url: newAudioFileURL, settings: [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100.0,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue,
                AVEncoderBitRateKey: 128000
            ])

            // Prepare the recorder (this creates the file)
            guard let recorder = audioRecorder, recorder.prepareToRecord() else {
                print("❌ Failed to prepare audio recorder")
                return
            }

            // Start recording
            if recorder.record() {
                print("✅ Audio recorder started, file: \(newAudioFileURL.lastPathComponent)")
            } else {
                print("❌ Failed to start audio recorder")
            }
        } catch {
            print("❌ Failed to setup audio recorder: \(error)")
            audioRecorder = nil
            audioFileURL = nil
        }

        // Install tap on input node
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }

        // Start audio engine
        audioEngine.prepare()
        do {
            try audioEngine.start()
            // Set isRecording on main thread to ensure UI updates properly
            DispatchQueue.main.async { [weak self] in
                self?.isRecording = true
                print("✅ Audio engine started, isRecording = true")
            }
        } catch {
            print("❌ Failed to start audio engine: \(error)")
            return
        }

        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let result = result {
                DispatchQueue.main.async {
                    self.transcript = result.bestTranscription.formattedString
                }
                // Log when we get results
                print("Recognition result - isFinal: \(result.isFinal), transcript length: \(result.bestTranscription.formattedString.count)")

                // If result is final, we might need to create a new recognition task to continue
                // But only if we're still supposed to be recording
                if result.isFinal && self.isRecording {
                    print("⚠️ Recognition task completed with final result, but still recording. This is normal - task will continue.")
                }
            }

            // Handle errors
            if let error = error {
                let nsError = error as NSError
                print("Recognition error - domain: \(nsError.domain), code: \(nsError.code), description: \(error.localizedDescription)")

                // If we're no longer recording, ignore errors (they're likely from cleanup)
                guard self.isRecording else {
                    print("Ignoring error - recording already stopped")
                    return
                }

                // Check error domain and code
                // Speech framework error codes
                let cancelledCode = 1  // SFSpeechRecognizerErrorCode.cancelled
                let notAvailableCode = 2  // SFSpeechRecognizerErrorCode.notAvailable
                let audioEngineUnavailableCode = 3  // SFSpeechRecognizerErrorCode.audioEngineUnavailable

                // Also check for cancellation errors in other domains (like kLSRErrorDomain code 301)
                let isCancellationError = nsError.code == cancelledCode ||
                                         (nsError.domain == "kLSRErrorDomain" && nsError.code == 301) ||
                                         error.localizedDescription.lowercased().contains("cancel")

                if isCancellationError {
                    // Cancellation is expected when user stops recording
                    print("Recognition cancelled (expected)")
                    return
                } else if nsError.code == notAvailableCode || nsError.code == audioEngineUnavailableCode {
                    // These are fatal errors that require stopping
                    print("Fatal recognition error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.stopRecording()
                    }
                } else {
                    // Other errors - log but don't stop (might be recoverable)
                    print("Recognition error (non-fatal, continuing): \(error.localizedDescription)")
                }
            }

            // Don't stop when result.isFinal is true - that just means we got a final transcription
            // Keep recording until user explicitly stops
            // The recognition task will continue to provide updates as long as audio is flowing
        }

        print("✅ Recognition task started")
    }

    func stopRecording() {
        print("🛑 stopRecording() called")
        // Safely stop the audio engine and remove tap
        if let engine = audioEngine {
            engine.stop()
            engine.inputNode.removeTap(onBus: 0)
            print("✅ Audio engine stopped")
        } else {
            print("⚠️ Audio engine was nil when stopRecording() called")
        }

        recognitionRequest?.endAudio()
        recognitionTask?.cancel()

        // Stop and finalize the audio recorder
        // This must be done before deactivating the audio session
        let recorderToFinalize = audioRecorder
        if let recorder = recorderToFinalize {
            let wasRecording = recorder.isRecording
            let fileURL = recorder.url
            if wasRecording {
                recorder.stop()
                print("✅ Audio recorder stopped: \(fileURL.lastPathComponent)")

                // Keep the recorder reference alive and wait for file finalization
                // M4A files need their headers written when recording stops
                // We need to ensure the file is fully written before we can play it
                let stopTime = Date()
                var finalized = false
                while !finalized && Date().timeIntervalSince(stopTime) < 0.5 {
                    // Check if file exists and has reasonable size
                    if FileManager.default.fileExists(atPath: fileURL.path) {
                        if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
                           let fileSize = attributes[.size] as? Int64 {
                            if fileSize > 1000 { // At least 1KB (reasonable for a short recording)
                                finalized = true
                                print("✅ Audio file finalized successfully, size: \(fileSize) bytes")
                            }
                        }
                    }
                    if !finalized {
                        // Small delay before checking again
                        RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 0.05))
                    }
                }
                if !finalized {
                    print("⚠️ Audio file may not be fully finalized")
                }
            } else {
                recorder.stop()
            }
        }

        // Deactivate audio session
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            print("✅ Audio session deactivated")
        } catch {
            print("⚠️ Failed to deactivate audio session: \(error)")
        }

        // Clean up references (after file is finalized)
        audioEngine = nil
        recognitionRequest = nil
        recognitionTask = nil
        audioRecorder = nil

        // Update UI state immediately (synchronously) to avoid race conditions
        isRecording = false
        print("✅ isRecording set to false")
    }

    func reset() {
        stopRecording()
        transcript = ""
        audioFileURL = nil
    }
}
