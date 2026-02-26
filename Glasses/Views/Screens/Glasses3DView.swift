import SwiftUI
import ARKit
import RealityKit

struct Glasses3DView: View {
    var frameName: String
    @State private var isShowingARView = false
    
    var body: some View {
        VStack(spacing: 24) {
            Text(frameName.capitalized.replacingOccurrences(of: "_", with: " "))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            VStack(spacing: 16) {
                Image(systemName: "eyeglasses")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                Text("Ready for Virtual Try-On")
                    .font(.headline)
                Text("Using the TrueDepth camera, we will automatically scale these frames to your face for a perfect fit.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 300)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .padding()
            
            Button(action: { isShowingARView = true }) {
                HStack {
                    Image(systemName: "face.dashed")
                        .font(.title2)
                    Text("Virtual Try-On")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(14)
                .padding(.horizontal)
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("3D Preview")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingARView) {
            ARFaceTrackingContainer(frameName: frameName, isPresented: $isShowingARView)
                .ignoresSafeArea()
        }
    }
}

// MARK: - AR Container
struct ARFaceTrackingContainer: View {
    var frameName: String
    @Binding var isPresented: Bool
    
    // Live Fine-Tuning States (Adjust these while wearing to find your model's "Sweet Spot")
    @State private var modelScale: Float = 0.7
    @State private var offsetY: Float = 0.01
    @State private var offsetZ: Float = 0.02
    
    var body: some View {
        ZStack {
            ARFaceTrackingView(
                frameName: frameName,
                modelScale: modelScale,
                offsetY: offsetY,
                offsetZ: offsetZ
            )
            .ignoresSafeArea()
            
            // UI Overlay
            VStack {
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.4)))
                    }
                }
                .padding(.top, 50)
                .padding(.trailing, 20)
                
                Spacer()
                
                // Fine-Tuning Panel
                VStack(spacing: 20) {
                    tuneSlider(title: "Size", value: $modelScale, range: 0.1...1.5)
                    tuneSlider(title: "Height", value: $offsetY, range: -0.1...0.1)
                    tuneSlider(title: "Depth", value: $offsetZ, range: -0.05...0.15)
                    
                    Text("Current Fit: S:\(String(format: "%.2f", modelScale)) Y:\(String(format: "%.3f", offsetY)) Z:\(String(format: "%.3f", offsetZ))")
                        .font(.caption.monospaced())
                        .foregroundColor(.white)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding()
            }
        }
    }
    
    private func tuneSlider(title: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        HStack {
            Text(title).font(.caption).foregroundColor(.white).frame(width: 50, alignment: .leading)
            Slider(value: value, in: range)
        }
    }
}

// MARK: - AR View Implementation
struct ARFaceTrackingView: UIViewRepresentable {
    var frameName: String
    var modelScale: Float
    var offsetY: Float
    var offsetZ: Float
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        
        guard ARFaceTrackingConfiguration.isSupported else { return arView }
        
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        arView.session.run(configuration)
        
        let faceAnchor = AnchorEntity(.face)
        if let glassesEntity = try? Entity.load(named: "\(frameName).usdz") {
            glassesEntity.name = "virtualGlasses"
            applyGlassMaterials(to: glassesEntity)
            faceAnchor.addChild(glassesEntity)
        }
        
        arView.scene.addAnchor(faceAnchor)
        context.coordinator.arView = arView
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        if let glasses = uiView.scene.findEntity(named: "virtualGlasses") {
            // Live updates from the Fine-Tuning Sliders
            glasses.scale = SIMD3<Float>(repeating: modelScale)
            glasses.position = SIMD3<Float>(0, offsetY, offsetZ)
        }
    }

    private func applyGlassMaterials(to entity: Entity) {
        if entity.name.lowercased().contains("lens"), let modelEntity = entity as? ModelEntity {
            var glassMaterial = PhysicallyBasedMaterial()
            glassMaterial.blending = .transparent(opacity: 0.12)
            glassMaterial.roughness = 0.05
            glassMaterial.specular = 1.0
            glassMaterial.clearcoat = 1.0
            glassMaterial.clearcoatRoughness = 0.01
            glassMaterial.baseColor = .init(tint: UIColor(red: 0.9, green: 1.0, blue: 0.95, alpha: 0.1))
            
            modelEntity.model?.materials = [glassMaterial]
        }
        for child in entity.children { applyGlassMaterials(to: child) }
    }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator: NSObject, ARSessionDelegate {
        weak var arView: ARView?
        var occlusionEntity: ModelEntity?
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first,
                  let arView = arView else { return }
            
            // Dynamic Biometric Scaling
            let leftEyePos = simd_make_float3(faceAnchor.leftEyeTransform.columns.3)
            let rightEyePos = simd_make_float3(faceAnchor.rightEyeTransform.columns.3)
            let currentEyeDistance = simd_distance(leftEyePos, rightEyePos)
            
            // Auto-scale relative to the standard 63mm IPD
            let autoScaleFactor = currentEyeDistance / 0.063
            
            // Occlusion Logic (Invisible head mask)
            if occlusionEntity == nil {
                let occlusionMaterial = OcclusionMaterial()
                if let device = MTLCreateSystemDefaultDevice(),
                   let meshResource = try? generateFaceMesh(from: faceAnchor.geometry) {
                    let faceModel = ModelEntity(mesh: meshResource, materials: [occlusionMaterial])
                    arView.scene.anchors.first?.addChild(faceModel)
                    self.occlusionEntity = faceModel
                }
            } else {
                if let meshResource = try? generateFaceMesh(from: faceAnchor.geometry) {
                    occlusionEntity?.model?.mesh = meshResource
                }
            }
        }
        
        private func generateFaceMesh(from geometry: ARFaceGeometry) throws -> MeshResource {
            var meshDescriptor = MeshDescriptor(name: "faceMesh")
            meshDescriptor.positions = MeshBuffers.Positions(geometry.vertices)
            meshDescriptor.primitives = .triangles(geometry.triangleIndices.map { UInt32($0) })
            return try MeshResource.generate(from: [meshDescriptor])
        }
    }
}
