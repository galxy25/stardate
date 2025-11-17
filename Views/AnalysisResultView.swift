//
//  AnalysisResultView.swift
//  StarDate
//

import SwiftUI

struct AnalysisResultView: View {
    let result: AnalysisResult
    @Environment(\.dismiss) var dismiss

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
                    .padding(.bottom, 40)
                }
            }
        }
    }
}
