//
//  NebulaLoader.swift
//  StarDate
//
//  Utility for loading and managing nebula assets
//

import Foundation
import RealityKit
import RealityKitContent
import SwiftUI
import Combine

@MainActor
class NebulaLoader: ObservableObject {
    @Published var loadedTextures: [String: TextureResource] = [:]
    @Published var isLoading = false

    private let nebulaNames = ["nebula_01", "nebula_02", "nebula_03"]

    func loadNebulaAssets() async {
        isLoading = true
        defer { isLoading = false }

        for name in nebulaNames {
            if let texture = try? await loadTexture(named: name) {
                loadedTextures[name] = texture
            }
        }
    }

    private func loadTexture(named name: String) async throws -> TextureResource? {
        // Try RealityKitContent bundle first
        if let texture = try? await TextureResource(named: name, in: realityKitContentBundle) {
            return texture
        }

        // Try main bundle
        let bundle = Bundle.main
        let extensions = ["jpg", "jpeg", "png", "hdr", "exr"]

        for ext in extensions {
            if let path = bundle.path(forResource: name, ofType: ext) {
                return try await TextureResource(contentsOf: URL(fileURLWithPath: path))
            }
        }

        // Try documents directory (for downloaded assets)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        for ext in extensions {
            let fileURL = documentsPath.appendingPathComponent("\(name).\(ext)")
            if FileManager.default.fileExists(atPath: fileURL.path) {
                return try await TextureResource(contentsOf: fileURL)
            }
        }

        return nil
    }

    func getRandomNebula() -> TextureResource? {
        let available = Array(loadedTextures.values)
        return available.randomElement()
    }
}

// Helper to download nebula images at runtime
extension NebulaLoader {
    func downloadNebula(from url: URL, name: String) async throws {
        let (data, _) = try await URLSession.shared.data(from: url)
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsPath.appendingPathComponent("\(name).jpg")
        try data.write(to: fileURL)

        // Reload textures
        await loadNebulaAssets()
    }
}

