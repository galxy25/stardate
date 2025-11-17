//
//  DiaryEntry.swift
//  StarDate
//

import Foundation

struct DiaryEntry: Identifiable, Codable {
    let id: UUID
    let starDate: String // UTC ISO timestamp
    let textTranscript: String
    let audioRecordingURL: URL?
    let summary: String?
    let joke: String?
    let advice: String?
    let createdAt: Date

    init(
        id: UUID = UUID(),
        starDate: String,
        textTranscript: String,
        audioRecordingURL: URL? = nil,
        summary: String? = nil,
        joke: String? = nil,
        advice: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.starDate = starDate
        self.textTranscript = textTranscript
        self.audioRecordingURL = audioRecordingURL
        self.summary = summary
        self.joke = joke
        self.advice = advice
        self.createdAt = createdAt
    }

    static func currentStarDate() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.string(from: Date())
    }
}
