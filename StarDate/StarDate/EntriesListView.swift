//
//  EntriesListView.swift
//  StarDate
//
//  View to display list of previous diary entries
//

import SwiftUI

struct EntriesListView: View {
    @EnvironmentObject var storageManager: DiaryStorageManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ZStack {
            StarfieldView()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()

                    Spacer()

                    Text("StarDate Entries")
                        .font(.title)
                        .foregroundColor(.white)

                    Spacer()

                    Color.clear
                        .frame(width: 60)
                }
                .padding()

                // Entries List
                if storageManager.entries.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()

                        Image(systemName: "book.closed")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.5))

                        Text("No entries yet")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.7))

                        Text("Create your first StarDate entry!")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.5))

                        Spacer()
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 20) {
                            ForEach(storageManager.entries.sorted(by: { $0.createdAt > $1.createdAt })) { entry in
                                EntryRowView(entry: entry)
                                    .environmentObject(storageManager)
                            }
                        }
                        .padding()
                    }
                }
            }
        }
    }
}

struct EntryRowView: View {
    let entry: DiaryEntry
    @EnvironmentObject var storageManager: DiaryStorageManager
    @State private var showDetail = false

    var body: some View {
        Button(action: {
            showDetail = true
        }) {
            VStack(alignment: .leading, spacing: 10) {
                // StarDate and Audio indicator
                HStack {
                Text(entry.starDate)
                    .font(.caption)
                    .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                    Spacer()

                    // Audio indicator
                    if entry.audioRecordingURL != nil {
                        HStack(spacing: 4) {
                            Image(systemName: "waveform")
                                .font(.caption2)
                            Text("Audio")
                                .font(.caption2)
                        }
                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.7))
                    }
                }

                // Preview of transcript
                Text(entry.textTranscript)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

                // Summary if available
                if let summary = entry.summary {
                    Text(summary)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.black.opacity(0.5))
            .cornerRadius(15)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetail) {
            EntryDetailView(entry: entry)
                .environmentObject(storageManager)
        }
    }
}

struct EntryDetailView: View {
    let entry: DiaryEntry
    @EnvironmentObject var storageManager: DiaryStorageManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var audioPlayer = AudioPlayerViewModel()
    @StateObject private var analyzer = ContentAnalyzer()

    @State private var currentEntry: DiaryEntry
    @State private var isProcessing = false
    @State private var analysisResult: AnalysisResult?
    @State private var showAnalysisResult = false

    init(entry: DiaryEntry) {
        self.entry = entry
        _currentEntry = State(initialValue: entry)
    }

    var body: some View {
        ZStack {
            StarfieldView()

            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // Header
                    HStack {
                        Button("Close") {
                            dismiss()
                        }
                        .foregroundColor(.white)
                        .padding()

                        Spacer()

                        Button(action: {
                            storageManager.deleteEntry(currentEntry)
                            dismiss()
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                                .padding()
                        }
                    }

                    // StarDate
                    VStack(alignment: .leading, spacing: 8) {
                        Text("StarDate")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                        Text(currentEntry.starDate)
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)

                    // Audio Player
                    if let audioURL = currentEntry.audioRecordingURL {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recording")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                            // Play/Pause button
                            HStack(spacing: 15) {
                                Button(action: {
                                    if audioPlayer.isPlaying {
                                        audioPlayer.pause()
                                    } else {
                                        // Load audio if not loaded yet or if there was an error
                                        if audioPlayer.duration == 0 || audioPlayer.playbackError != nil {
                                            audioPlayer.loadAudio(from: audioURL)
                                        }
                                        // Only play if we have a valid player (no error)
                                        if audioPlayer.playbackError == nil {
                                            audioPlayer.play()
                                        }
                                    }
                                }) {
                                    Image(systemName: audioPlayer.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                        .font(.system(size: 40))
                                        .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))
                                }
                                .buttonStyle(.plain)

                                // Time display
                                VStack(alignment: .leading, spacing: 4) {
                                    if let error = audioPlayer.playbackError {
                                        Text(error)
                                            .font(.caption)
                                            .foregroundColor(.red.opacity(0.8))
                                    } else if audioPlayer.duration > 0 {
                                        Text(formatTime(audioPlayer.currentTime) + " / " + formatTime(audioPlayer.duration))
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.7))

                                        // Progress bar
                                        GeometryReader { geometry in
                                            ZStack(alignment: .leading) {
                                                Rectangle()
                                                    .fill(Color.white.opacity(0.2))
                                                    .frame(height: 4)

                                                Rectangle()
                                                    .fill(Color(red: 0.0, green: 0.8, blue: 0.8))
                                                    .frame(width: geometry.size.width * CGFloat(audioPlayer.currentTime / max(audioPlayer.duration, 1)), height: 4)
                                            }
                                        }
                                        .frame(height: 4)
                                    } else {
                                        Text("Tap to load audio")
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.5))
                                    }
                                }

                                Spacer()

                                // Stop button
                                if audioPlayer.isPlaying || audioPlayer.currentTime > 0 {
                                    Button(action: {
                                        audioPlayer.stop()
                                    }) {
                                        Image(systemName: "stop.circle.fill")
                                            .font(.system(size: 30))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }

                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(15)
                    }

                    // Transcript
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                        Text("Transcript")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                            Spacer()

                            // Analyze button
                            Button(action: {
                                analyzeContent()
                            }) {
                                HStack(spacing: 6) {
                                    if isProcessing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                    } else {
                                        Image(systemName: currentEntry.summary != nil ? "sparkles.rectangle.stack" : "sparkles")
                                    }
                                    Text(isProcessing ? "Analyzing..." : (currentEntry.summary != nil ? "Re-analyze" : "Analyze"))
                                        .font(.caption)
                                }
                                .foregroundColor(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
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
                                .cornerRadius(15)
                            }
                            .buttonStyle(.plain)
                            .disabled(isProcessing || currentEntry.textTranscript.isEmpty)
                        }

                        Text(currentEntry.textTranscript)
                            .font(.body)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(Color.black.opacity(0.5))
                    .cornerRadius(15)

                    // Summary
                    if let summary = currentEntry.summary {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Summary")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                            Text(summary)
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(15)
                    }

                    // Joke
                    if let joke = currentEntry.joke {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Joke")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                            Text(joke)
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(15)
                    }

                    // Advice
                    if let advice = currentEntry.advice {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Advice")
                                .font(.headline)
                                .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                            Text(advice)
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(15)
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showAnalysisResult) {
            if let result = analysisResult {
                AnalysisResultView(result: result, onSave: {
                    saveAnalysis(result)
                })
            }
        }
        .onDisappear {
            // Stop audio when view disappears
            Task { @MainActor in
                audioPlayer.stop()
            }
        }
    }

    private func analyzeContent() {
        guard !currentEntry.textTranscript.isEmpty else { return }

        print("🔍 Analyzing entry: \(currentEntry.id)")
        isProcessing = true

        Task {
            do {
                let result = try await analyzer.analyze(content: currentEntry.textTranscript)

                await MainActor.run {
                    analysisResult = result
                    isProcessing = false
                    showAnalysisResult = true
                }
            } catch {
                print("❌ Failed to analyze entry: \(error)")
                await MainActor.run {
                    isProcessing = false
                    // Show error to user - you might want to add an error state here
                }
            }
        }
    }

    private func saveAnalysis(_ result: AnalysisResult) {
        print("💾 Saving analysis for entry: \(currentEntry.id)")

        // Create updated entry with analysis results
        let updatedEntry = DiaryEntry(
            id: currentEntry.id,
            starDate: currentEntry.starDate,
            textTranscript: currentEntry.textTranscript,
            audioRecordingURL: currentEntry.audioRecordingURL,
            summary: result.summary,
            joke: result.joke,
            advice: result.advice,
            createdAt: currentEntry.createdAt
        )

        // Update the entry in storage
        storageManager.updateEntry(updatedEntry)

        // Update local state
        currentEntry = updatedEntry

        // Dismiss the analysis result sheet
        showAnalysisResult = false

        print("✅ Analysis saved successfully")
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}
