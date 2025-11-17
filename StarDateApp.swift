//
//  StarDateApp.swift
//  StarDate
//
//  Created for Vision Pro
//

import SwiftUI

@main
struct StarDateApp: App {
    @StateObject private var storageManager = DiaryStorageManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(storageManager)
        }
        .windowStyle(.volumetric)
        .defaultSize(width: 1.0, height: 1.0, depth: 1.0, in: .meters)
    }
}
