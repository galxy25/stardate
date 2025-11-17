//
//  RecordingView.swift
//  StarDate
//

import SwiftUI

struct RecordingView: View {
    @EnvironmentObject var storageManager: DiaryStorageManager
    @Environment(\.dismiss) var dismiss

    @StateObject private var recorder = AudioRecorder()
    @StateObject private var analyzer = ContentAnalyzer()

    @State private var transcript = ""
    @State private var isProcessing = false
    @State private var analysisResult: AnalysisResult?
    @State private var showResult = false

    var body: some View {
        ZStack {
            StarfieldView()

            VStack(spacing: 40) {
                // Header
                HStack {
                    Button("Close") {
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
                    if !recorder.isRecording && transcript.isEmpty {
                        Button(action: startRecording) {
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
                    } else if recorder.isRecording {
                        Button(action: stopRecording) {
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
                        Button(action: analyzeContent) {
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

                        Button(action: saveEntry) {
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
        .onChange(of: recorder.transcript) { newValue in
            transcript = newValue
        }
        .onChange(of: recorder.isRecording) { newValue in
            // Sync state if needed
        }
    }

    private func startRecording() {
        transcript = ""
        recorder.reset()
        recorder.startRecording()
    }

    private func stopRecording() {
        recorder.stopRecording()
    }

    private func analyzeContent() {
        guard !transcript.isEmpty else { return }

        isProcessing = true

        Task {
            let result = await analyzer.analyze(content: transcript)

            await MainActor.run {
                analysisResult = result
                isProcessing = false
                showResult = true
            }
        }
    }

    private func saveEntry() {
        let audioURL = recorder.audioFileURL
        let entry = DiaryEntry(
            starDate: DiaryEntry.currentStarDate(),
            textTranscript: transcript,
            audioRecordingURL: audioURL,
            summary: analysisResult?.summary,
            joke: analysisResult?.joke,
            advice: analysisResult?.advice
        )

        storageManager.saveEntry(entry)
        recorder.reset()
        dismiss()
    }
}
