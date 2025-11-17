//
//  ImmersiveView.swift
//  StarDate
//
//  Updated to support nebula backgrounds
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {
    @Environment(AppModel.self) var appModel

    var body: some View {
        RealityView { content in
            // Create nebula sky dome
            let nebulaEntity = await createNebulaSkyDome()
            content.add(nebulaEntity)

            // Add the initial RealityKit content (if it exists)
            if let immersiveContentEntity = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                // Remove the default SkyDome if we're using our nebula
                if let skyDome = immersiveContentEntity.findEntity(named: "SkyDome") {
                    skyDome.removeFromParent()
                }
                content.add(immersiveContentEntity)
            }
        }
    }

    @MainActor
    func createNebulaSkyDome() async -> Entity {
        // Create a large sphere for the sky dome
        let skyDome = MeshResource.generateSphere(radius: 1000)

        // Try to load nebula texture, fallback to starfield if not available
        var material: any RealityKit.Material

        if let nebulaTexture = try? await TextureResource(named: "nebula_01", in: realityKitContentBundle) {
            // Use nebula texture - use UnlitMaterial for sky domes
            var unlit = UnlitMaterial()
            unlit.color = .init(tint: .white, texture: .init(nebulaTexture))
            material = unlit
        } else if let nebulaTexture = try? await loadNebulaTexture() {
            // Load from bundle or documents
            var unlit = UnlitMaterial()
            unlit.color = .init(tint: .white, texture: .init(nebulaTexture))
            material = unlit
        } else {
            // Fallback: Create procedural nebula material
            material = createProceduralNebulaMaterial()
        }

        let skyDomeEntity = ModelEntity(mesh: skyDome, materials: [material])

        // Flip the sphere inside-out so we see it from inside
        skyDomeEntity.scale = SIMD3<Float>(1, 1, -1)

        return skyDomeEntity
    }

    func loadNebulaTexture() async throws -> TextureResource? {
        // Try to load from app bundle
        let bundle = Bundle.main
        if let imagePath = bundle.path(forResource: "nebula_01", ofType: "jpg") ??
                          bundle.path(forResource: "nebula_01", ofType: "png") {
            return try await TextureResource(contentsOf: URL(fileURLWithPath: imagePath))
        }

        // Try RealityKitContent bundle
        if let texture = try? await TextureResource(named: "nebula_01", in: realityKitContentBundle) {
            return texture
        }

        return nil
    }

    func createProceduralNebulaMaterial() -> any RealityKit.Material {
        // Create a procedural nebula-like material if no texture is available
        // This creates a space-like background with stars and nebula colors

        // For now, use a simple dark blue material with some color variation
        // In a full implementation, you could use a shader or more complex material
        return SimpleMaterial(
            color: .init(
                red: 0.05,
                green: 0.05,
                blue: 0.15,
                alpha: 1.0
            ),
            roughness: 1.0,
            isMetallic: false
        )
    }
}

// Helper extension to find entities by name
extension Entity {
    func findEntity(named name: String) -> Entity? {
        if self.name == name {
            return self
        }
        for child in children {
            if let found = child.findEntity(named: name) {
                return found
            }
        }
        return nil
    }
}

#Preview(immersionStyle: .progressive) {
    ImmersiveView()
        .environment(AppModel())
}
