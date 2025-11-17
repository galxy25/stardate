//
//  AnalysisResultView.swift
//  StarDate
//

import SwiftUI

struct AnalysisResultView: View {
    let result: AnalysisResult
    let onSave: (() -> Void)?
    @Environment(\.dismiss) var dismiss

    init(result: AnalysisResult, onSave: (() -> Void)? = nil) {
        self.result = result
        self.onSave = onSave
    }

    var body: some View {
        ZStack {
            StarfieldView()

            ScrollView {
                VStack(spacing: 30) {
                    Text("Analysis Complete")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding(.top)

                    // Summary
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Summary")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                        Text(result.summary)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)

                    // Joke
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Joke")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                        Text(result.joke)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)

                    // Advice
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Advice")
                            .font(.headline)
                            .foregroundColor(Color(red: 0.0, green: 0.8, blue: 0.8))

                        Text(result.advice)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.5))
                            .cornerRadius(15)
                    }
                    .padding(.horizontal)

                    // Action buttons
                    HStack(spacing: 20) {
                        if let onSave = onSave {
                            Button("Save Analysis") {
                                onSave()
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            .padding(.vertical, 15)
                            .background(Color.green)
                            .cornerRadius(25)
                        }

                        Button("Close") {
                            dismiss()
                        }
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
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
