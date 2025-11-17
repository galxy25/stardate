//
//  ContentView.swift
//  StarDate
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var storageManager: DiaryStorageManager
    @State private var showRecordingView = false

    var body: some View {
        ZStack {
            StarfieldView()

            VStack {
                Spacer()

                Button(action: {
                    showRecordingView = true
                }) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.0, green: 0.8, blue: 0.8),
                                        Color(red: 0.0, green: 0.6, blue: 0.7)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 120, height: 120)
                            .shadow(color: Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.8), radius: 30)
                            .shadow(color: Color(red: 0.0, green: 0.8, blue: 0.8).opacity(0.4), radius: 50)

                        Image(systemName: "mic.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                .padding(.bottom, 100)

                Spacer()
            }
        }
        .fullScreenCover(isPresented: $showRecordingView) {
            RecordingView()
                .environmentObject(storageManager)
        }
    }
}
