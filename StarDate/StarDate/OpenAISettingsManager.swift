//
//  OpenAISettingsManager.swift
//  StarDate
//
//  Manages OpenAI API configuration settings

import Foundation
import Combine

class OpenAISettingsManager: ObservableObject {
    static let shared = OpenAISettingsManager()

    @Published var apiKey: String {
        didSet {
            UserDefaults.standard.set(apiKey, forKey: "OPEN_API_KEY")
        }
    }

    @Published var model: String {
        didSet {
            UserDefaults.standard.set(model, forKey: "OPEN_API_MODEL")
        }
    }

    @Published var endpoint: String {
        didSet {
            UserDefaults.standard.set(endpoint, forKey: "OPEN_API_ENDPOINT")
        }
    }

    @Published var maxCompletionTokens: Int {
        didSet {
            UserDefaults.standard.set(maxCompletionTokens, forKey: "OPEN_API_MAX_COMPLETION_TOKENS")
        }
    }

    var isConfigured: Bool {
        !apiKey.isEmpty && !model.isEmpty && !endpoint.isEmpty
    }

    private init() {
        // Load settings from UserDefaults with defaults
        self.apiKey = UserDefaults.standard.string(forKey: "OPEN_API_KEY") ?? ""
        self.model = UserDefaults.standard.string(forKey: "OPEN_API_MODEL") ?? "gpt-4o"
        self.endpoint = UserDefaults.standard.string(forKey: "OPEN_API_ENDPOINT") ?? "https://api.openai.com/v1/chat/completions"
        // Default to 2000 for reasoning models like GPT-5
        self.maxCompletionTokens = UserDefaults.standard.object(forKey: "OPEN_API_MAX_COMPLETION_TOKENS") as? Int ?? 2000
    }

    func resetToDefaults() {
        apiKey = ""
        model = "gpt-4o"
        endpoint = "https://api.openai.com/v1/chat/completions"
        maxCompletionTokens = 2000
    }
}
