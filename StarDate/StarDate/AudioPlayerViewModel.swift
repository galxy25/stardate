//
//  AudioPlayerViewModel.swift
//  StarDate
//

import AVFoundation
import Combine

@MainActor
class AudioPlayerViewModel: ObservableObject {
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playbackError: String?

    private var player: AVAudioPlayer?
    nonisolated(unsafe) private var timer: Timer?
    private var audioURL: URL?

    func loadAudio(from url: URL) {
        print("🎵 Loading audio from: \(url.path)")

        // Reset previous state
        playbackError = nil
        duration = 0
        currentTime = 0

        // Check if file exists
        guard FileManager.default.fileExists(atPath: url.path) else {
            print("❌ Audio file does not exist at path: \(url.path)")
            playbackError = "Audio file not found"
            player = nil
            return
        }

        audioURL = url

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = AudioPlayerDelegate(viewModel: self)
            player?.prepareToPlay()
            duration = player?.duration ?? 0
            playbackError = nil
            print("✅ Audio loaded successfully, duration: \(duration)s")
        } catch {
            print("❌ Failed to load audio: \(error)")
            playbackError = "Failed to load audio: \(error.localizedDescription)"
            player = nil
            duration = 0
        }
    }

    func play() {
        guard let player = player, !isPlaying else { return }

        print("▶️ Starting playback")

        // Configure audio session for playback
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("⚠️ Failed to setup audio session for playback: \(error)")
        }

        isPlaying = player.play()

        if isPlaying {
            startTimer()
        } else {
            print("❌ Failed to start playback")
            playbackError = "Failed to start playback"
        }
    }

    func pause() {
        guard let player = player, isPlaying else { return }

        print("⏸ Pausing playback")
        player.pause()
        isPlaying = false
        stopTimer()
    }

    func stop() {
        print("⏹ Stopping playback")

        if let player = player {
            player.stop()
            player.currentTime = 0
        }

        isPlaying = false
        currentTime = 0
        stopTimer()

        // Deactivate audio session
        try? AVAudioSession.sharedInstance().setActive(false)
    }

    func seek(to time: TimeInterval) {
        guard let player = player else { return }
        player.currentTime = time
        currentTime = time
    }

    private func startTimer() {
        stopTimer()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                guard let self = self, let player = self.player else { return }
                self.currentTime = player.currentTime
            }
        }
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    deinit {
        // Clean up synchronously to avoid retain cycles
        // deinit can access MainActor-isolated properties
        timer?.invalidate()
        timer = nil
        player?.stop()
        player = nil
    }
}

// Delegate to handle audio player events
private class AudioPlayerDelegate: NSObject, AVAudioPlayerDelegate {
    weak var viewModel: AudioPlayerViewModel?

    init(viewModel: AudioPlayerViewModel) {
        self.viewModel = viewModel
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor [weak viewModel] in
            guard let viewModel = viewModel else { return }
            viewModel.isPlaying = false
            viewModel.currentTime = 0
            viewModel.stopTimer()
            print("✅ Playback finished successfully: \(flag)")
        }
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        Task { @MainActor [weak viewModel] in
            guard let viewModel = viewModel else { return }
            viewModel.isPlaying = false
            viewModel.playbackError = error?.localizedDescription ?? "Playback error"
            print("❌ Audio decode error: \(error?.localizedDescription ?? "unknown")")
        }
    }
}
