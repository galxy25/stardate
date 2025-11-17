//
//  RecordingView.swift
//  StarDate
//

import SwiftUI

struct RecordingView: View {
    @EnvironmentObject var storageManager: DiaryStorageManager
    @Environment(\.dismiss) var dismiss

    // Use @StateObject with explicit initialization to ensure stability
    @StateObject private var recorder: AudioRecorder = {
        let r = AudioRecorder()
        print("🎤 AudioRecorder created in RecordingView")
        return r
    }()
    @StateObject private var analyzer: ContentAnalyzer = {
        let a = ContentAnalyzer()
        print("🔍 ContentAnalyzer created in RecordingView")
        return a
    }()

    @State private var transcript = ""
    @State private var isProcessing = false
    @State private var analysisResult: AnalysisResult?
    @State private var showResult = false
    @State private var showAnalysisError = false
    @State private var analysisErrorMessage: String = ""
    @State private var isStartingRecording = false // Guard to prevent multiple taps
    @State private var isStoppingRecording = false // Guard to prevent multiple taps

    init() {
        print("🎬 RecordingView init() called")
    }

    var body: some View {
        ZStack {
            StarfieldView()
                .id("starfield") // Give StarfieldView a stable identity

            VStack(spacing: 40) {
                // Header
                HStack {
                    Button("Close") {
                        print("❌ Close button tapped in RecordingView")
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()

                    Spacer()

                    Text("StarDate Entry")
                        .font(.title)
                        .foregroundColor(.white)

                    Spacer()

                    // Spacer for balance
                    Color.clear
                        .frame(width: 60)
                }
                .padding()

                Spacer()

                // Recording indicator
                if recorder.isRecording {
                    VStack(spacing: 20) {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 60, height: 60)
                            .overlay(
                                Circle()
                                    .stroke(Color.red.opacity(0.5), lineWidth: 2)
                                    .scaleEffect(recorder.isRecording ? 1.5 : 1.0)
                                    .opacity(recorder.isRecording ? 0 : 1)
                                    .animation(
                                        Animation.easeInOut(duration: 1.0)
                                            .repeatForever(autoreverses: false),
                                        value: recorder.isRecording
                                    )
                            )

                        Text("Recording...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }

                // Transcript display
                if !transcript.isEmpty {
                    ScrollView {
                        Text(transcript)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 300)
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)
                    .padding(.horizontal)
                }

                // Processing indicator
                if isProcessing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)

                    Text("Analyzing your entry...")
                        .foregroundColor(.white)
                        .font(.headline)
                }

                // Action buttons
                HStack(spacing: 30) {
                    if !recorder.isRecording && transcript.isEmpty && !isStartingRecording {
                        Button(action: {
                            print("🎤 Start recording button tapped")
                            guard !isStartingRecording && !recorder.isRecording else {
                                print("⚠️ Already starting recording, ignoring tap")
                                return
                            }
                            startRecording()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.0, green: 0.8, blue: 0.8),
                                                Color(red: 0.0, green: 0.6, blue: 0.7)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                    .shadow(color: Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.8), radius: 20)

                                Image(systemName: "mic.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    } else if recorder.isRecording && !isStoppingRecording {
                        Button(action: {
                            print("🛑 Stop recording button tapped")
                            guard !isStoppingRecording else {
                                print("⚠️ Already stopping recording, ignoring tap")
                                return
                            }
                            stopRecording()
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 100, height: 100)

                                Image(systemName: "stop.fill")
                                    .font(.system(size: 35))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    } else if !transcript.isEmpty && !isProcessing {
                        Button(action: {
                            print("🔍 Analyze button tapped")
                            analyzeContent()
                        }) {
                            Text("Analyze")
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.0, green: 0.8, blue: 0.8),
                                            Color(red: 0.0, green: 0.6, blue: 0.7)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(25)
                        }
                        .buttonStyle(.plain)

                        Button(action: {
                            print("💾 Save button tapped - transcript length: \(transcript.count)")
                            saveEntry()
                        }) {
                            Text("Save")
                                .foregroundColor(.white)
                                .padding(.horizontal, 40)
                                .padding(.vertical, 15)
                                .background(Color.green)
                                .cornerRadius(25)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 100)

                Spacer()
            }
        }
        .sheet(isPresented: $showResult) {
            if let result = analysisResult {
                AnalysisResultView(result: result)
            }
        }
        .onChange(of: recorder.transcript) { oldValue, newValue in
            // Only update transcript if new value is not empty
            // This prevents the final empty recognition result from clearing the transcript
            if !newValue.isEmpty {
                if transcript != newValue {
                    transcript = newValue
                    print("📝 Transcript updated: length = \(newValue.count)")
                }
            } else if transcript.isEmpty {
                // Only set to empty if we don't have a transcript yet
                transcript = newValue
            } else {
                print("⚠️ Ignoring empty transcript update (preserving existing transcript of length \(transcript.count))")
            }
        }
        .onChange(of: recorder.isRecording) { oldValue, newValue in
            // Only log if the value actually changed to avoid state update loops
            if oldValue != newValue {
                print("🎤 Recording state changed: \(oldValue) -> \(newValue)")
                // Reset guards when recording state changes
                if !newValue {
                    isStartingRecording = false
                    isStoppingRecording = false
                }
            }
        }
        .onAppear {
            print("✅ RecordingView onAppear called")
            print("   Thread: \(Thread.isMainThread ? "Main" : "Background")")
        }
        .onDisappear {
            print("👋 RecordingView onDisappear called")
        }
        .alert("Analysis Failed", isPresented: $showAnalysisError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(analysisErrorMessage)
        }
    }

    private func startRecording() {
        guard !isStartingRecording && !recorder.isRecording else {
            print("⚠️ startRecording() called but already starting or recording")
            return
        }

        isStartingRecording = true
        transcript = ""
        // Don't call reset() here - startRecording() will handle cleanup
        // This avoids double-calling stopRecording() which causes race conditions
        recorder.startRecording()

        // Reset the guard after a short delay to allow state to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isStartingRecording = false
        }
    }

    private func stopRecording() {
        guard !isStoppingRecording else {
            print("⚠️ stopRecording() called but already stopping")
            return
        }

        isStoppingRecording = true
        recorder.stopRecording()

        // Reset the guard after a short delay to allow state to update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isStoppingRecording = false
        }
    }

    private func analyzeContent() {
        guard !transcript.isEmpty else { return }

        isProcessing = true

        Task {
            do {
                let result = try await analyzer.analyze(content: transcript)
                await MainActor.run {
                    analysisResult = result
                    isProcessing = false
                    showResult = true
                }
            } catch {
                print("❌ Analysis failed: \(error)")
                await MainActor.run {
                    isProcessing = false
                    analysisErrorMessage = error.localizedDescription
                    showAnalysisError = true
                }
            }
        }
    }

    private func saveEntry() {
        print("💾 RecordingView.saveEntry() called")
        print("   Thread: \(Thread.isMainThread ? "Main" : "Background")")


        guard !transcript.isEmpty else {
            print("⚠️ Cannot save entry: transcript is empty")
            return
        }

        // Ensure we're on the main thread for UI operations
        guard Thread.isMainThread else {
            print("⚠️ saveEntry() called off main thread, dispatching to main")
            DispatchQueue.main.async {
                self.saveEntry()
            }
            return
        }

        let audioURL = recorder.audioFileURL
        print("   Audio URL: \(audioURL?.absoluteString ?? "nil")")

        // Verify audio file exists if URL is provided
        if let audioURL = audioURL {
            let fileExists = FileManager.default.fileExists(atPath: audioURL.path)
            print("   Audio file exists: \(fileExists)")
            if !fileExists {
                print("⚠️ Warning: Audio file does not exist at path: \(audioURL.path)")
            }
        }

        let entry = DiaryEntry(
            starDate: DiaryEntry.currentStarDate(),
            textTranscript: transcript,
            audioRecordingURL: audioURL,
            summary: analysisResult?.summary,
            joke: analysisResult?.joke,
            advice: analysisResult?.advice
        )

        print("   Created entry with ID: \(entry.id)")
        print("   Entry transcript length: \(entry.textTranscript.count)")
        print("   Entry has summary: \(entry.summary != nil)")
        print("   Entry has joke: \(entry.joke != nil)")
        print("   Entry has advice: \(entry.advice != nil)")

        // Save entry
        storageManager.saveEntry(entry)

        // Ensure audio session is cleaned up
        recorder.reset()

        // Small delay to ensure save completes, then dismiss
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("💾 Dismissing RecordingView after save")
            self.dismiss()
        }
    }
}
