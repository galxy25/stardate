//
//  ContentView.swift
//  StarDate
//
//  Home screen with two buttons: Record New Entry and View Entries
//

import SwiftUI

struct ContentView: View {
    @StateObject private var storageManager = DiaryStorageManager()
    @StateObject private var settingsManager = OpenAISettingsManager.shared
    @State private var showRecordingView = false
    @State private var showEntriesView = false
    @State private var showSettingsView = false
    @State private var isPresentingRecordingView = false

    var body: some View {
        ZStack {
            StarfieldView()

            VStack(spacing: 40) {
                Spacer()

                // Title
                HStack {
                    Spacer()
                    Button(action: {
                        showSettingsView = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .padding(.top)

                Text("StarDate")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.bottom, 60)


                // Record New Entry Button
                Button(action: {
                    print("🎬 Record button tapped")
                    print("   Current showRecordingView: \(showRecordingView)")
                    print("   Current isPresentingRecordingView: \(isPresentingRecordingView)")
                    print("   Thread: \(Thread.isMainThread ? "Main" : "Background")")

                    // Prevent multiple rapid taps
                    guard !showRecordingView && !isPresentingRecordingView else {
                        print("⚠️ Already presenting recording view, ignoring tap")
                        return
                    }

                    print("   Setting showRecordingView = true")
                    isPresentingRecordingView = true
                    showRecordingView = true
                    print("   showRecordingView after set: \(showRecordingView)")
                    print("   isPresentingRecordingView after set: \(isPresentingRecordingView)")
                }) {
                    VStack(spacing: 15) {
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

                        Text("New Entry")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)

                // View Entries Button
                Button(action: {
                    showEntriesView = true
                }) {
                    VStack(spacing: 15) {
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

                            Image(systemName: "list.bullet")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                        }

                        Text("View Entries")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)

                Spacer()
            }
        }
        .onChange(of: showRecordingView) { oldValue, newValue in
            print("🔄 showRecordingView changed: \(oldValue) -> \(newValue)")
            print("   Thread: \(Thread.isMainThread ? "Main" : "Background")")
            if !newValue {
                // Reset the presenting flag when dismissed
                isPresentingRecordingView = false
                print("   Reset isPresentingRecordingView to false")
            }
        }
        .fullScreenCover(isPresented: $showRecordingView) {
            // Create the view once and reuse it to prevent recreations
            RecordingView()
                .environmentObject(storageManager)
                .onAppear {
                    print("📱 fullScreenCover presented - RecordingView appeared")
                    print("   showRecordingView: \(showRecordingView)")
                }
                .onDisappear {
                    print("📱 fullScreenCover dismissed - RecordingView disappeared")
                    // Ensure state is reset
                    showRecordingView = false
                    isPresentingRecordingView = false
                }
        }
        .sheet(isPresented: $showEntriesView) {
            EntriesListView()
                .environmentObject(storageManager)
        }
        .sheet(isPresented: $showSettingsView) {
            SettingsView()
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
}
