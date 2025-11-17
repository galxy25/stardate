//
//  StarfieldView.swift
//  StarDate
//

import SwiftUI

struct StarfieldView: View {
    @State private var stars: [Star] = []

    struct Star: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
    }

    init() {
        generateStars()
    }

    private func generateStars() {
        stars = (0..<200).map { _ in
            Star(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: 0...1),
                size: CGFloat.random(in: 1...3),
                opacity: Double.random(in: 0.3...1.0)
            )
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                    .ignoresSafeArea()

                ForEach(stars) { star in
                    Circle()
                        .fill(Color.white)
                        .frame(width: star.size, height: star.size)
                        .position(
                            x: star.x * geometry.size.width,
                            y: star.y * geometry.size.height
                        )
                        .opacity(star.opacity)
                }
            }
        }
    }
}
