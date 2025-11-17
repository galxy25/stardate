//
//  AppIconView.swift
//  StarDate
//
//  SwiftUI view for generating the app icon programmatically
//

import SwiftUI

struct AppIconView: View {
    var body: some View {
        ZStack {
            // Background gradient
            RadialGradient(
                colors: [
                    Color(red: 0.04, green: 0.04, blue: 0.10),
                    Color(red: 0.10, green: 0.10, blue: 0.23),
                    Color(red: 0.16, green: 0.16, blue: 0.35),
                    Color(red: 0.04, green: 0.04, blue: 0.10)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 512
            )

            // Warp lines converging to center
            WarpLinesView()

            // Stars with warp effect
            StarfieldWarpView()

            // Center warp point
            CenterWarpPointView()
        }
        .frame(width: 1024, height: 1024)
    }
}

struct WarpLinesView: View {
    var body: some View {
        ZStack {
            // Horizontal lines
            ForEach([256, 384, 512, 640, 768], id: \.self) { y in
                Line(from: CGPoint(x: 0, y: CGFloat(y)),
                     to: CGPoint(x: 512, y: 512))
                    .stroke(Color(red: 0.0, green: 1.0, blue: 1.0),
                           lineWidth: y == 512 ? 3 : 2)
                    .opacity(y == 512 ? 0.6 : 0.4)

                Line(from: CGPoint(x: 1024, y: CGFloat(y)),
                     to: CGPoint(x: 512, y: 512))
                    .stroke(Color(red: 0.0, green: 1.0, blue: 1.0),
                           lineWidth: 2)
                    .opacity(0.4)
            }

            // Vertical lines
            ForEach([256, 384, 512, 640, 768], id: \.self) { x in
                Line(from: CGPoint(x: CGFloat(x), y: 0),
                     to: CGPoint(x: 512, y: 512))
                    .stroke(Color(red: 0.0, green: 1.0, blue: 1.0),
                           lineWidth: x == 512 ? 3 : 2)
                    .opacity(x == 512 ? 0.6 : 0.4)

                Line(from: CGPoint(x: CGFloat(x), y: 1024),
                     to: CGPoint(x: 512, y: 512))
                    .stroke(Color(red: 0.0, green: 1.0, blue: 1.0),
                           lineWidth: 2)
                    .opacity(0.4)
            }
        }
    }
}

struct Line: Shape {
    var from: CGPoint
    var to: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        path.addLine(to: to)
        return path
    }
}

struct StarfieldWarpView: View {
    var body: some View {
        ZStack {
            // Outer stars (smaller, dimmer)
            ForEach(outerStars, id: \.id) { star in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 1.0, blue: 1.0),
                                Color(red: 0.0, green: 0.67, blue: 1.0),
                                Color.white
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat(star.size), height: CGFloat(star.size))
                    .position(star.position)
                    .opacity(star.opacity)
                    .blur(radius: 1)
            }

            // Mid-range stars (medium)
            ForEach(midStars, id: \.id) { star in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 1.0, blue: 1.0),
                                Color(red: 0.0, green: 0.67, blue: 1.0),
                                Color.white
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat(star.size), height: CGFloat(star.size))
                    .position(star.position)
                    .opacity(star.opacity)
                    .blur(radius: 0.5)
            }

            // Inner stars (larger, brighter)
            ForEach(innerStars, id: \.id) { star in
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.0, green: 1.0, blue: 1.0),
                                Color(red: 0.0, green: 0.67, blue: 1.0),
                                Color.white
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: CGFloat(star.size), height: CGFloat(star.size))
                    .position(star.position)
                    .opacity(star.opacity)
                    .blur(radius: 0.5)

                // Motion blur streak
                Ellipse()
                    .fill(Color(red: 0.0, green: 1.0, blue: 1.0))
                    .frame(width: 15, height: 3)
                    .position(star.position)
                    .opacity(0.5)
                    .rotationEffect(.degrees(star.angle))
            }
        }
    }

    struct Star {
        let id = UUID()
        let position: CGPoint
        let size: CGFloat
        let opacity: Double
        let angle: Double
    }

    let outerStars: [Star] = [
        Star(position: CGPoint(x: 150, y: 200), size: 4, opacity: 0.7, angle: -45),
        Star(position: CGPoint(x: 874, y: 150), size: 4, opacity: 0.7, angle: 45),
        Star(position: CGPoint(x: 200, y: 824), size: 4, opacity: 0.7, angle: 45),
        Star(position: CGPoint(x: 824, y: 874), size: 4, opacity: 0.7, angle: -45),
        Star(position: CGPoint(x: 100, y: 500), size: 4, opacity: 0.7, angle: 0),
        Star(position: CGPoint(x: 924, y: 500), size: 4, opacity: 0.7, angle: 180),
        Star(position: CGPoint(x: 500, y: 100), size: 4, opacity: 0.7, angle: 90),
        Star(position: CGPoint(x: 500, y: 924), size: 4, opacity: 0.7, angle: -90)
    ]

    let midStars: [Star] = [
        Star(position: CGPoint(x: 300, y: 300), size: 6, opacity: 0.8, angle: -45),
        Star(position: CGPoint(x: 724, y: 300), size: 6, opacity: 0.8, angle: 45),
        Star(position: CGPoint(x: 300, y: 724), size: 6, opacity: 0.8, angle: 45),
        Star(position: CGPoint(x: 724, y: 724), size: 6, opacity: 0.8, angle: -45),
        Star(position: CGPoint(x: 350, y: 450), size: 6, opacity: 0.8, angle: -30),
        Star(position: CGPoint(x: 674, y: 450), size: 6, opacity: 0.8, angle: 30),
        Star(position: CGPoint(x: 350, y: 574), size: 6, opacity: 0.8, angle: 30),
        Star(position: CGPoint(x: 674, y: 574), size: 6, opacity: 0.8, angle: -30),
        Star(position: CGPoint(x: 450, y: 300), size: 6, opacity: 0.8, angle: 90),
        Star(position: CGPoint(x: 574, y: 300), size: 6, opacity: 0.8, angle: 90),
        Star(position: CGPoint(x: 450, y: 724), size: 6, opacity: 0.8, angle: -90),
        Star(position: CGPoint(x: 574, y: 724), size: 6, opacity: 0.8, angle: -90)
    ]

    let innerStars: [Star] = [
        Star(position: CGPoint(x: 400, y: 400), size: 8, opacity: 0.9, angle: -45),
        Star(position: CGPoint(x: 624, y: 400), size: 8, opacity: 0.9, angle: 45),
        Star(position: CGPoint(x: 400, y: 624), size: 8, opacity: 0.9, angle: 45),
        Star(position: CGPoint(x: 624, y: 624), size: 8, opacity: 0.9, angle: -45),
        Star(position: CGPoint(x: 450, y: 450), size: 10, opacity: 0.95, angle: -45),
        Star(position: CGPoint(x: 574, y: 450), size: 10, opacity: 0.95, angle: 45),
        Star(position: CGPoint(x: 450, y: 574), size: 10, opacity: 0.95, angle: 45),
        Star(position: CGPoint(x: 574, y: 574), size: 10, opacity: 0.95, angle: -45)
    ]
}

struct CenterWarpPointView: View {
    var body: some View {
        ZStack {
            // Outer glow
            Circle()
                .fill(Color(red: 0.0, green: 1.0, blue: 1.0))
                .frame(width: 32, height: 32)
                .opacity(0.15)
                .blur(radius: 8)

            // Mid glow
            Circle()
                .fill(Color(red: 0.0, green: 1.0, blue: 1.0))
                .frame(width: 24, height: 24)
                .opacity(0.3)
                .blur(radius: 4)

            // Center star
            Circle()
                .fill(Color(red: 0.0, green: 1.0, blue: 1.0))
                .frame(width: 16, height: 16)
                .opacity(1.0)
                .blur(radius: 1)
        }
        .position(x: 512, y: 512)
    }
}

#Preview {
    AppIconView()
        .frame(width: 512, height: 512)
        .scaleEffect(0.5)
}
