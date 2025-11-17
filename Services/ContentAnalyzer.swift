//
//  ContentAnalyzer.swift
//  StarDate
//

import Foundation
import NaturalLanguage

class ContentAnalyzer: ObservableObject {

    func analyze(content: String) async -> AnalysisResult {
        // Generate summary using Natural Language framework
        let summary = generateSummary(from: content)

        // Generate a joke based on content sentiment
        let joke = generateJoke(from: content)

        // Generate advice based on content analysis
        let advice = generateAdvice(from: content)

        return AnalysisResult(
            summary: summary,
            joke: joke,
            advice: advice
        )
    }

    private func generateSummary(from content: String) -> String {
        // Use Natural Language framework to extract key phrases and create a summary
        let tagger = NLTagger(tagSchemes: [.sentimentScore, .lexicalClass])
        tagger.string = content

        // Extract key sentences (simplified approach)
        let sentences = content.components(separatedBy: CharacterSet(charactersIn: ".!?"))
            .filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }

        // Get sentiment
        var sentimentScore: Double = 0
        tagger.enumerateTags(in: content.startIndex..<content.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, tokenRange in
            if let tag = tag, let score = Double(tag.rawValue) {
                sentimentScore += score
            }
            return true
        }

        let sentiment = sentimentScore > 0 ? "positive" : sentimentScore < 0 ? "negative" : "neutral"

        // Create summary from first few sentences and sentiment
        let summarySentences = Array(sentences.prefix(min(3, sentences.count)))
        let summaryText = summarySentences.joined(separator: ". ") + "."

        return "Your entry has a \(sentiment) tone. Key points: \(summaryText)"
    }

    private func generateJoke(from content: String) -> String {
        // Analyze content to generate contextually relevant jokes
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = content

        var nouns: [String] = []
        tagger.enumerateTags(in: content.startIndex..<content.endIndex, unit: .word, scheme: .lexicalClass) { tag, tokenRange in
            if tag == .noun {
                let word = String(content[tokenRange])
                nouns.append(word.lowercased())
            }
            return true
        }

        // Simple joke generation based on content
        let jokes = [
            "Why did the diary entry go to space? Because it wanted to reach for the stars! 🌟",
            "What do you call a diary entry that's out of this world? A StarDate entry! ⭐",
            "Why don't diary entries ever get lost? Because they're always written in the stars! ✨",
            "What's a diary entry's favorite planet? Diary-us! (Get it? Like Uranus, but for diaries!) 🪐",
            "Why did the astronaut break up with their diary? Because it was too spacey! 🚀"
        ]

        // Return a random joke (in a real app, you'd use more sophisticated AI)
        return jokes.randomElement() ?? jokes[0]
    }

    private func generateAdvice(from content: String) -> String {
        // Analyze sentiment and keywords to provide advice
        let tagger = NLTagger(tagSchemes: [.sentimentScore, .lexicalClass])
        tagger.string = content

        var sentimentScore: Double = 0
        tagger.enumerateTags(in: content.startIndex..<content.endIndex, unit: .paragraph, scheme: .sentimentScore) { tag, tokenRange in
            if let tag = tag, let score = Double(tag.rawValue) {
                sentimentScore += score
            }
            return true
        }

        // Extract emotional keywords
        let emotionalWords = ["happy", "sad", "excited", "worried", "anxious", "grateful", "frustrated", "proud", "disappointed", "hopeful"]
        let lowercasedContent = content.lowercased()
        let foundEmotions = emotionalWords.filter { lowercasedContent.contains($0) }

        // Generate advice based on sentiment
        if sentimentScore < -0.3 {
            return "It sounds like you're going through a challenging time. Remember that every star in the sky has its moment to shine, and so do you. Consider talking to someone you trust or taking time for self-care. Your feelings are valid, and brighter days are ahead."
        } else if sentimentScore > 0.3 {
            return "It's wonderful to hear about your positive experiences! Keep nurturing these moments of joy. Consider writing more about what made you feel this way - it can help you recreate these feelings in the future. Your positivity is like a star that lights up the night sky!"
        } else {
            return "Your entry reflects a balanced perspective. Continue to observe and reflect on your experiences. Sometimes the most profound insights come from simply being present with our thoughts. Keep exploring your inner universe - every entry is a step forward in your journey."
        }
    }
}
