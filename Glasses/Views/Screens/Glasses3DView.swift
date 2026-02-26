import SwiftUI
import SceneKit
import ARKit
import RealityKit

struct Glasses3DView: View {
    var frameName: String
    @State private var isShowingARView = false
    
    private var scene: SCNScene? {
        return SCNScene(named: "\(frameName).usdz")
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(frameName.capitalized.replacingOccurrences(of: "_", with: " "))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            if scene != nil {
                SceneView(
                    scene: scene,
                    options: [.autoenablesDefaultLighting, .allowsCameraControl]
                )
                .frame(height: 400)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding()
                
                // AR Try-On Button
                Button(action: {
                    isShowingARView = true
                }) {
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
                
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "arkit")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Add '\(frameName).usdz' to your project to view the 3D model.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding()
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("3D Preview")
        .navigationBarTitleDisplayMode(.inline)
        // Presents the full-screen AR experience
        .fullScreenCover(isPresented: $isShowingARView) {
            ARFaceTrackingContainer(frameName: frameName, isPresented: $isShowingARView)
                .ignoresSafeArea()
        }
    }
}

struct ARFaceTrackingContainer: View {
    var frameName: String
    @Binding var isPresented: Bool
    
    // Debugger State Variables
    @State private var modelScale: Float = 1.0
    @State private var offsetX: Float = 0.0
    @State private var offsetY: Float = 0.0
    @State private var offsetZ: Float = 0.02 // Starts slightly forward so it doesn't clip into the nose
    
    var body: some View {
        ZStack {
            // The AR Camera View
            ARFaceTrackingView(
                frameName: frameName,
                modelScale: modelScale,
                offsetX: offsetX,
                offsetY: offsetY,
                offsetZ: offsetZ
            )
            .ignoresSafeArea()
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.4)))
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
            
            // MARK: - Live Debugger Panel
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Live Positioning Debugger")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    debugSlider(title: "Scale", value: $modelScale, range: 0.1...3.0)
                    debugSlider(title: "X (L/R)", value: $offsetX, range: -0.1...0.1)
                    debugSlider(title: "Y (Up/Dn)", value: $offsetY, range: -0.1...0.1)
                    debugSlider(title: "Z (In/Out)", value: $offsetZ, range: -0.1...0.2)
                    
                    Text("Copy these values when it looks right!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    // Helper view for the debugger sliders
    private func debugSlider(title: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        HStack {
            Text("\(title):")
                .font(.caption.monospacedDigit())
                .frame(width: 75, alignment: .leading)
            
            Slider(value: value, in: range)
                .tint(.accentColor)
            
            Text(String(format: "%.3f", value.wrappedValue))
                .font(.caption.monospacedDigit())
                .frame(width: 50, alignment: .trailing)
        }
    }
}

struct ARFaceTrackingView: UIViewRepresentable {
    var frameName: String
    
    // Incoming values from the SwiftUI sliders
    var modelScale: Float
    var offsetX: Float
    var offsetY: Float
    var offsetZ: Float
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return arView
        }
        
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
        
        if let glassesEntity = try? Entity.load(named: "\(frameName).usdz") {
            // 1. Give the entity a specific name so we can find it later to update it
            glassesEntity.name = "virtualGlasses"
            
            let faceAnchor = AnchorEntity(.face)
            faceAnchor.addChild(glassesEntity)
            arView.scene.addAnchor(faceAnchor)
        }
        
        return arView
    }
    
    // This function runs automatically every time a slider is dragged!
    func updateUIView(_ uiView: ARView, context: Context) {
        // 2. Find the glasses model in the scene
        guard let glassesEntity = uiView.scene.findEntity(named: "virtualGlasses") else { return }
        
        // 3. Update its size and position instantly
        glassesEntity.scale = SIMD3<Float>(repeating: modelScale)
        glassesEntity.position = SIMD3<Float>(offsetX, offsetY, offsetZ)
    }
}
