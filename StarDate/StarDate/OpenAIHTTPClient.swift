//
//  OpenAIHTTPClient.swift
//  StarDate
//
//  HTTP client for OpenAI API communication

import Foundation

struct OpenAIRequest: Codable {
    let model: String
    let messages: [OpenAIMessage]
    let temperature: Double?
    let maxCompletionTokens: Int?

    enum CodingKeys: String, CodingKey {
        case model
        case messages
        case temperature
        case maxCompletionTokens = "max_completion_tokens"
    }

    // Only encode temperature if it's not nil and not the default value of 1.0
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(model, forKey: .model)
        try container.encode(messages, forKey: .messages)
        try container.encode(maxCompletionTokens, forKey: .maxCompletionTokens)
        // Only encode temperature if it's set and not 1.0 (default)
        if let temp = temperature, temp != 1.0 {
            try container.encode(temp, forKey: .temperature)
        }
    }
}

struct OpenAIMessage: Codable {
    let role: String
    let content: String
}

struct OpenAIResponse: Codable {
    let id: String?
    let object: String?
    let created: Int?
    let model: String?
    let choices: [OpenAIChoice]?
    let usage: OpenAIUsage?
    let error: OpenAIError?
}

struct OpenAIChoice: Codable {
    let index: Int?
    let message: OpenAIMessage?
    let finishReason: String?

    enum CodingKeys: String, CodingKey {
        case index
        case message
        case finishReason = "finish_reason"
    }
}

struct OpenAIUsage: Codable {
    let promptTokens: Int?
    let completionTokens: Int?
    let totalTokens: Int?

    enum CodingKeys: String, CodingKey {
        case promptTokens = "prompt_tokens"
        case completionTokens = "completion_tokens"
        case totalTokens = "total_tokens"
    }
}

struct OpenAIError: Codable {
    let message: String
    let type: String?
    let code: String?
}

enum OpenAIErrorType: Error {
    case invalidConfiguration
    case networkError(Error)
    case apiError(String)
    case invalidResponse
    case decodingError(Error)
}

@MainActor
class OpenAIHTTPClient {
    private let settingsManager = OpenAISettingsManager.shared
    private let session = URLSession.shared

    func analyzeContent(_ content: String) async throws -> AnalysisResult {
        print("🌐 OpenAIHTTPClient.analyzeContent() called")
        print("   Content length: \(content.count) characters")

        guard settingsManager.isConfigured else {
            print("❌ OpenAI not configured")
            throw OpenAIErrorType.invalidConfiguration
        }

        print("   Model: \(settingsManager.model)")
        print("   Endpoint: \(settingsManager.endpoint)")
        print("   API Key: \(settingsManager.apiKey.prefix(7))...")

        // Create the prompt for analysis
        let systemPrompt = """
        You are a helpful AI assistant that analyzes diary entries. For each entry, provide:
        1. A concise summary (2-3 sentences) capturing the main themes and sentiment
        2. A lighthearted, space-themed joke related to the content
        3. Personalized, empathetic advice based on the entry's emotional tone

        You MUST respond ONLY with valid JSON in this exact format (no markdown, no code blocks, just raw JSON):
        {
          "summary": "Your summary here",
          "joke": "Your joke here",
          "advice": "Your advice here"
        }
        """

        let userPrompt = """
        Please analyze this diary entry:

        \(content)
        """

        print("   System prompt length: \(systemPrompt.count) characters")
        print("   User prompt length: \(userPrompt.count) characters")

        // GPT-5 and other reasoning models use tokens for internal reasoning
        // We need more tokens to account for both reasoning and output
        let request = OpenAIRequest(
            model: settingsManager.model,
            messages: [
                OpenAIMessage(role: "system", content: systemPrompt),
                OpenAIMessage(role: "user", content: userPrompt)
            ],
            temperature: nil, // Use default temperature (1.0) - some models don't support custom temperature
            maxCompletionTokens: settingsManager.maxCompletionTokens
        )

        print("📤 Making API request...")
        print("   Request model: \(request.model)")
        print("   Request messages count: \(request.messages.count)")
        print("   Request maxCompletionTokens: \(request.maxCompletionTokens ?? 0)")

        // Make the API call
        let response = try await makeRequest(request)

        print("📥 Received API response")
        print("   Response ID: \(response.id ?? "nil")")
        print("   Response model: \(response.model ?? "nil")")
        print("   Response choices count: \(response.choices?.count ?? 0)")
        print("   Response error: \(response.error?.message ?? "nil")")

        // Log detailed choice information
        if let choices = response.choices {
            for (index, choice) in choices.enumerated() {
                print("   Choice \(index):")
                print("     Index: \(choice.index ?? -1)")
                print("     Finish reason: \(choice.finishReason ?? "nil")")
                print("     Message role: \(choice.message?.role ?? "nil")")
                print("     Message content length: \(choice.message?.content.count ?? 0)")
                print("     Message content: \(choice.message?.content ?? "nil")")
            }
        }

        // Parse the response
        guard let firstChoice = response.choices?.first else {
            print("❌ No choices in response")
            if let error = response.error {
                print("   Error message: \(error.message)")
                print("   Error type: \(error.type ?? "nil")")
                print("   Error code: \(error.code ?? "nil")")
                throw OpenAIErrorType.apiError(error.message)
            }
            print("   No error object in response")
            throw OpenAIErrorType.invalidResponse
        }

        // Check finish reason
        if let finishReason = firstChoice.finishReason {
            print("   Finish reason: \(finishReason)")
            if finishReason != "stop" {
                print("⚠️ Warning: Finish reason is '\(finishReason)', not 'stop'")
                if finishReason == "length" {
                    print("   The response was cut off due to token limit")
                } else if finishReason == "content_filter" {
                    print("   The response was filtered by content policy")
                }
            }
        }

        guard let responseContent = firstChoice.message?.content else {
            print("❌ No content in response message")
            print("   Finish reason: \(firstChoice.finishReason ?? "nil")")
            if let error = response.error {
                print("   Error message: \(error.message)")
                print("   Error type: \(error.type ?? "nil")")
                print("   Error code: \(error.code ?? "nil")")
                throw OpenAIErrorType.apiError(error.message)
            }
            print("   No error object in response")
            throw OpenAIErrorType.apiError("Empty response content. Finish reason: \(firstChoice.finishReason ?? "unknown")")
        }

        print("✅ Response content received")
        print("   Content length: \(responseContent.count) characters")
        print("   Content preview: \(String(responseContent.prefix(200)))...")

        // Clean the content - remove markdown code blocks if present
        var cleanedContent = responseContent.trimmingCharacters(in: .whitespacesAndNewlines)
        print("   Cleaning content...")
        if cleanedContent.hasPrefix("```json") {
            cleanedContent = String(cleanedContent.dropFirst(7))
            print("   Removed ```json prefix")
        } else if cleanedContent.hasPrefix("```") {
            cleanedContent = String(cleanedContent.dropFirst(3))
            print("   Removed ``` prefix")
        }
        if cleanedContent.hasSuffix("```") {
            cleanedContent = String(cleanedContent.dropLast(3))
            print("   Removed ``` suffix")
        }
        cleanedContent = cleanedContent.trimmingCharacters(in: .whitespacesAndNewlines)
        print("   Cleaned content length: \(cleanedContent.count) characters")
        print("   Cleaned content preview: \(String(cleanedContent.prefix(200)))...")

        // Try to parse JSON response
        print("🔍 Attempting JSON parsing...")
        if let jsonData = cleanedContent.data(using: .utf8) {
            print("   JSON data size: \(jsonData.count) bytes")
            do {
                let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any]
                if let json = json {
                    print("✅ JSON parsing successful")
                    print("   JSON keys: \(json.keys.joined(separator: ", "))")

                    let summary = json["summary"] as? String ?? "Unable to generate summary."
                    let joke = json["joke"] as? String ?? "Why did the diary entry go to space? Because it wanted to reach for the stars! 🌟"
                    let advice = json["advice"] as? String ?? "Continue reflecting on your experiences. Every entry is a step forward in your journey."

                    print("   Parsed summary length: \(summary.count)")
                    print("   Parsed joke length: \(joke.count)")
                    print("   Parsed advice length: \(advice.count)")

                    return AnalysisResult(summary: summary, joke: joke, advice: advice)
                } else {
                    print("❌ JSON is not a dictionary")
                }
            } catch {
                print("❌ JSON parsing error: \(error)")
                print("   JSON data: \(String(data: jsonData, encoding: .utf8) ?? "invalid UTF-8")")
            }
        } else {
            print("❌ Failed to convert content to UTF-8 data")
        }

        // If JSON parsing fails, try to extract sections from plain text
        print("⚠️ JSON parsing failed, attempting plain text parsing...")
        return parsePlainTextResponse(responseContent)
    }

    private func makeRequest(_ request: OpenAIRequest) async throws -> OpenAIResponse {
        print("🌐 makeRequest() called")

        guard let url = URL(string: settingsManager.endpoint) else {
            print("❌ Invalid endpoint URL: \(settingsManager.endpoint)")
            throw OpenAIErrorType.invalidConfiguration
        }

        print("   URL: \(url.absoluteString)")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(settingsManager.apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        print("   HTTP Method: POST")
        print("   Authorization header: Bearer \(settingsManager.apiKey.prefix(7))...")

        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = []
            urlRequest.httpBody = try encoder.encode(request)
            print("   Request body size: \(urlRequest.httpBody?.count ?? 0) bytes")
            if let bodyData = urlRequest.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
                print("   Request body preview: \(String(bodyString.prefix(500)))...")
            }
        } catch {
            print("❌ Failed to encode request: \(error)")
            throw OpenAIErrorType.decodingError(error)
        }

        do {
            print("📡 Sending HTTP request...")
            let (data, response) = try await session.data(for: urlRequest)
            print("📥 Received HTTP response")
            print("   Response data size: \(data.count) bytes")

            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ Response is not HTTPURLResponse")
                throw OpenAIErrorType.invalidResponse
            }

            print("   HTTP Status Code: \(httpResponse.statusCode)")
            print("   HTTP Headers: \(httpResponse.allHeaderFields)")

            guard (200...299).contains(httpResponse.statusCode) else {
                print("❌ HTTP error status: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("   Error response body: \(responseString)")
                }
                // Try to parse error response
                if let errorResponse = try? JSONDecoder().decode(OpenAIResponse.self, from: data),
                   let error = errorResponse.error {
                    print("   Parsed error: \(error.type ?? "nil") - \(error.message)")
                    throw OpenAIErrorType.apiError("\(error.type ?? "Error"): \(error.message)")
                }
                throw OpenAIErrorType.apiError("HTTP \(httpResponse.statusCode)")
            }

            print("✅ HTTP request successful, decoding response...")

            // Log raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("   Raw response body: \(responseString)")
            }

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let openAIResponse = try decoder.decode(OpenAIResponse.self, from: data)
            print("✅ Response decoded successfully")
            return openAIResponse

        } catch let error as OpenAIErrorType {
            print("❌ OpenAIErrorType: \(error)")
            throw error
        } catch {
            print("❌ Network error: \(error)")
            print("   Error type: \(type(of: error))")
            throw OpenAIErrorType.networkError(error)
        }
    }

    private func parsePlainTextResponse(_ text: String) -> AnalysisResult {
        print("📝 parsePlainTextResponse() called")
        print("   Text length: \(text.count) characters")
        // Fallback parsing if JSON parsing fails
        let lines = text.components(separatedBy: .newlines).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        var summary = "Unable to generate summary."
        var joke = "Why did the diary entry go to space? Because it wanted to reach for the stars! 🌟"
        var advice = "Continue reflecting on your experiences. Every entry is a step forward in your journey."

        // Try to find sections
        var currentSection: String? = nil
        var summaryLines: [String] = []
        var jokeLines: [String] = []
        var adviceLines: [String] = []

        for line in lines {
            let lowerLine = line.lowercased()
            if lowerLine.contains("summary") || lowerLine.contains("summary:") {
                currentSection = "summary"
                if let colonRange = line.range(of: ":") {
                    let afterColon = String(line[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    if !afterColon.isEmpty {
                        summaryLines.append(afterColon)
                    }
                }
            } else if lowerLine.contains("joke") || lowerLine.contains("joke:") {
                currentSection = "joke"
                if let colonRange = line.range(of: ":") {
                    let afterColon = String(line[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    if !afterColon.isEmpty {
                        jokeLines.append(afterColon)
                    }
                }
            } else if lowerLine.contains("advice") || lowerLine.contains("advice:") {
                currentSection = "advice"
                if let colonRange = line.range(of: ":") {
                    let afterColon = String(line[colonRange.upperBound...]).trimmingCharacters(in: .whitespaces)
                    if !afterColon.isEmpty {
                        adviceLines.append(afterColon)
                    }
                }
            } else if let section = currentSection {
                switch section {
                case "summary":
                    summaryLines.append(line)
                case "joke":
                    jokeLines.append(line)
                case "advice":
                    adviceLines.append(line)
                default:
                    break
                }
            }
        }

        if !summaryLines.isEmpty {
            summary = summaryLines.joined(separator: " ")
        }
        if !jokeLines.isEmpty {
            joke = jokeLines.joined(separator: " ")
        }
        if !adviceLines.isEmpty {
            advice = adviceLines.joined(separator: " ")
        }

        return AnalysisResult(summary: summary, joke: joke, advice: advice)
    }
}
