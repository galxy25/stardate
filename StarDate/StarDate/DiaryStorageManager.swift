//
//  DiaryStorageManager.swift
//  StarDate
//

import Foundation
import Combine

class DiaryStorageManager: ObservableObject {
    @Published var entries: [DiaryEntry] = []

    private let entriesKey = "StarDateEntries"
    private let documentsDirectory: URL

    init() {
        documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        loadEntries()
    }

    func saveEntry(_ entry: DiaryEntry) {
        print("💾 saveEntry() called for entry: \(entry.id)")
        print("   Transcript length: \(entry.textTranscript.count)")
        print("   Audio URL: \(entry.audioRecordingURL?.absoluteString ?? "nil")")

        entries.append(entry)

        do {
            try saveEntries()
            print("✅ Entry saved successfully")
        } catch {
            print("❌ Failed to save entry: \(error)")
            print("   Error details: \(error.localizedDescription)")
            // Remove the entry we just added since save failed
            entries.removeAll { $0.id == entry.id }
            // Re-throw or handle error appropriately
            // For now, we'll log and continue, but this should be handled by the caller
        }
    }

    func updateEntry(_ entry: DiaryEntry) {
        print("💾 updateEntry() called for entry: \(entry.id)")

        // Find and update the entry
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry

            do {
                try saveEntries()
                print("✅ Entry updated successfully")
            } catch {
                print("❌ Failed to update entry: \(error)")
                print("   Error details: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ Entry not found for update: \(entry.id)")
        }
    }

    func deleteEntry(_ entry: DiaryEntry) {
        entries.removeAll { $0.id == entry.id }

        // Delete audio file if it exists
        if let audioURL = entry.audioRecordingURL {
            try? FileManager.default.removeItem(at: audioURL)
        }

        do {
            try saveEntries()
        } catch {
            print("❌ Failed to save after deleting entry: \(error)")
        }
    }

    private func saveEntries() throws {
        print("💾 saveEntries() called - saving \(entries.count) entries")

        // Save entry metadata (excluding audio URLs which are file paths)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted // For debugging

        do {
            let encoded = try encoder.encode(entries)
            let dataSize = encoded.count
            print("   Encoded data size: \(dataSize) bytes")

            UserDefaults.standard.set(encoded, forKey: entriesKey)

            // Verify it was saved
            if UserDefaults.standard.synchronize() {
                print("✅ Entries saved to UserDefaults successfully")
            } else {
                print("⚠️ UserDefaults.synchronize() returned false")
            }
        } catch {
            print("❌ Encoding error: \(error)")
            if let encodingError = error as? EncodingError {
                switch encodingError {
                case .invalidValue(let value, let context):
                    print("   Invalid value: \(value)")
                    print("   Context: \(context.debugDescription)")
                @unknown default:
                    print("   Unknown encoding error")
                }
            }
            throw error
        }
    }

    private func loadEntries() {
        guard let data = UserDefaults.standard.data(forKey: entriesKey) else {
            print("📂 No saved entries found")
            return
        }

        print("📂 Loading entries from UserDefaults (\(data.count) bytes)")

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        do {
            let decoded = try decoder.decode([DiaryEntry].self, from: data)
            entries = decoded
            print("✅ Loaded \(decoded.count) entries successfully")
        } catch {
            print("❌ Failed to decode entries: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("   Data corrupted: \(context.debugDescription)")
                case .keyNotFound(let key, let context):
                    print("   Key not found: \(key.stringValue)")
                    print("   Context: \(context.debugDescription)")
                case .typeMismatch(let type, let context):
                    print("   Type mismatch: \(type)")
                    print("   Context: \(context.debugDescription)")
                case .valueNotFound(let type, let context):
                    print("   Value not found: \(type)")
                    print("   Context: \(context.debugDescription)")
                @unknown default:
                    print("   Unknown decoding error")
                }
            }
            // Clear corrupted data
            entries = []
        }
    }
}
