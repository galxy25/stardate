//
//  ContentAnalyzer.swift
//  StarDate
//
//  Analyzes diary entries using OpenAI API (GPT models)

import Foundation
import SwiftUI
import Combine

@MainActor
class ContentAnalyzer: ObservableObject {
    private let openAIClient = OpenAIHTTPClient()
    private let settingsManager = OpenAISettingsManager.shared

    func analyze(content: String) async throws -> AnalysisResult {
        print("🔍 ContentAnalyzer.analyze() called")
        print("   Content length: \(content.count) characters")
        print("   OpenAI configured: \(settingsManager.isConfigured)")

        guard settingsManager.isConfigured else {
            print("❌ OpenAI not configured - cannot analyze")
            throw OpenAIErrorType.invalidConfiguration
        }

        do {
            let result = try await openAIClient.analyzeContent(content)
            print("✅ ContentAnalyzer.analyze() completed successfully")
            print("   Summary length: \(result.summary.count)")
            print("   Joke length: \(result.joke.count)")
            print("   Advice length: \(result.advice.count)")
            return result
        } catch {
            print("❌ ContentAnalyzer.analyze() failed with error: \(error)")
            throw error
        }
    }

}
