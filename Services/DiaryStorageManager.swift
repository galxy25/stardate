//
//  DiaryStorageManager.swift
//  StarDate
//

import Foundation

class DiaryStorageManager: ObservableObject {
    @Published var entries: [DiaryEntry] = []

    private let entriesKey = "StarDateEntries"
    private let documentsDirectory: URL

    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        loadEntries()
    }

    func saveEntry(_ entry: DiaryEntry) {
        entries.append(entry)
        saveEntries()
    }

    func deleteEntry(_ entry: DiaryEntry) {
        entries.removeAll { $0.id == entry.id }

        // Delete audio file if it exists
        if let audioURL = entry.audioRecordingURL {
            try? FileManager.default.removeItem(at: audioURL)
        }

        saveEntries()
    }

    private func saveEntries() {
        // Save entry metadata (excluding audio URLs which are file paths)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        if let encoded = try? encoder.encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
            return
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let decoded = try? decoder.decode([DiaryEntry].self, from: data) {
            entries = decoded
        }
    }
}
