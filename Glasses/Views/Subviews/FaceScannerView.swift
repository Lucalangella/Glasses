import SwiftUI
import ARKit
import SceneKit

// MARK: - State Machine
enum ScanState {
    case intro
    case scanning
    case processing
    case results
}

struct FaceScanResults {
    var pd: Double = 0.0
    var faceShape: String = "Oval"
    var frameWidth: String = "Medium, Narrow"
    var noseBridge: String = "Standard"
}

// MARK: - Main View
struct FaceScannerView: View {
    @Binding var isPresented: Bool
    @Binding var finalPD: String
    
    @State private var state: ScanState = .intro
    @State private var progress: CGFloat = 0.0
    @State private var statusText: String = "Measuring"
    @State private var scanResults = FaceScanResults()
    
    var body: some View {
        ZStack {
            // 1. The Live AR Camera & Mesh
            ARFaceTrackingEngine(
                state: $state,
                progress: $progress,
                statusText: $statusText,
                results: $scanResults
            )
            .ignoresSafeArea()
            
            // 2. Top Bar (Close Button & Progress)
            VStack {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.leading, 16)
                
                if state == .scanning || state == .processing {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 4)
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .trim(from: 0, to: progress)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.1), value: progress)
                        }
                        
                        Text(statusText)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }
                    .transition(.opacity)
                }
                
                Spacer()
            }
            
            // 3. Bottom Sheets
            VStack {
                Spacer()
                
                if state == .intro {
                    IntroSheetView(state: $state)
                        .transition(.move(edge: .bottom))
                } else if state == .results {
                    ResultsSheetView(
                        results: scanResults,
                        onContinue: {
                            // Update the ViewModel's PD and dismiss
                            finalPD = String(format: "%.1f", scanResults.pd)
                            isPresented = false
                        },
                        onRescan: {
                            // Reset state to try again
                            progress = 0
                            state = .scanning
                        }
                    )
                    .transition(.move(edge: .bottom))
                }
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: state)
    }
}

// MARK: - Bottom Sheets
struct IntroSheetView: View {
    @Binding var state: ScanState
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Advisor")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.3)) // Dark green
            
            Text("For best results")
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("1. Remove your glasses before your start")
                Text("2. Hold the phone an arms length away")
                Text("3. Face the camera straight on")
                Text("4. Follow the indicator on screen")
            }
            .font(.subheadline)
            .foregroundColor(.black.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            Button(action: {
                state = .scanning
            }) {
                Text("Got it")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.top, 32)
        .background(Color.white)
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
}

struct ResultsSheetView: View {
    var results: FaceScanResults
    var onContinue: () -> Void
    var onRescan: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Advisor")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color(red: 0.1, green: 0.4, blue: 0.3))
            
            Text("Your face scan results")
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
            
            VStack(spacing: 16) {
                ResultRow(icon: "faceid", title: "Face shape", value: results.faceShape)
                ResultRow(icon: "eyeglasses", title: "Suggested frame widths", value: results.frameWidth)
                ResultRow(icon: "nose", title: "Recommended nose bridge", value: results.noseBridge)
                
                // PD Row (Expanded)
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                        VStack(alignment: .leading) {
                            Text("Pupillary Distance (PD)").font(.caption).foregroundColor(.secondary)
                            Text(String(format: "%.1fmm", results.pd)).font(.headline).foregroundColor(.black)
                        }
                        Spacer()
                    }
                    Text("Pupillary distance (PD) is the distance between your pupils. This measurement is used to help center a prescription correctly in your frames.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 38)
                        .padding(.top, 4)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.2), lineWidth: 1))
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(30)
                }
                
                Button(action: onRescan) {
                    Text("Rescan")
                        .font(.headline)
                        .foregroundColor(.black)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.top, 32)
        .background(Color.white)
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
}

struct ResultRow: View {
    var icon: String
    var title: String
    var value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.teal)
                .frame(width: 30)
            
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .foregroundColor(.black)
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - ARKit Engine
struct ARFaceTrackingEngine: UIViewRepresentable {
    @Binding var state: ScanState
    @Binding var progress: CGFloat
    @Binding var statusText: String
    @Binding var results: FaceScanResults
    
    func makeUIView(context: Context) -> ARSCNView {
        let arView = ARSCNView(frame: .zero)
        arView.delegate = context.coordinator
        arView.session.delegate = context.coordinator
        arView.backgroundColor = .clear
        
        guard ARFaceTrackingConfiguration.isSupported else { return arView }
        
        let config = ARFaceTrackingConfiguration()
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        return arView
    }
    
    func updateUIView(_ uiView: ARSCNView, context: Context) {
        // When state changes to processing, tell the coordinator to show the mesh
        context.coordinator.showMesh = (state == .processing)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSCNViewDelegate, ARSessionDelegate {
        var parent: ARFaceTrackingEngine
        var faceNode: SCNNode?
        var showMesh: Bool = false {
            didSet {
                faceNode?.isHidden = !showMesh
            }
        }
        
        // Data collection
        var pdMeasurements: [Double] = []
        let requiredFrames = 60 // Takes about 1 second of good tracking
        
        init(_ parent: ARFaceTrackingEngine) {
            self.parent = parent
        }
        
        // 1. Create the Wireframe Mesh Node
        func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
            guard let device = renderer.device, anchor is ARFaceAnchor else { return nil }
            
            let faceGeometry = ARSCNFaceGeometry(device: device)
            let node = SCNNode(geometry: faceGeometry)
            
            // Style the mesh to look like the video (white lines)
            node.geometry?.firstMaterial?.fillMode = .lines
            node.geometry?.firstMaterial?.diffuse.contents = UIColor.white.withAlphaComponent(0.8)
            node.isHidden = true // Hidden until we reach .processing state
            
            self.faceNode = node
            return node
        }
        
        // 2. Update the Mesh Shape as the face moves
        func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
            guard let faceAnchor = anchor as? ARFaceAnchor,
                  let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
            faceGeometry.update(from: faceAnchor.geometry)
        }
        
        // 3. Process the Math Frame by Frame
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            guard parent.state == .scanning,
                  let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
            
            // Check if the user is looking at the camera
            let lookAtPoint = faceAnchor.lookAtPoint
            let isLookingAtCamera = abs(lookAtPoint.x) < 0.1 && abs(lookAtPoint.y) < 0.1
            
            DispatchQueue.main.async {
                self.parent.statusText = isLookingAtCamera ? "Measuring" : "Look forward and hold still"
            }
            
            guard isLookingAtCamera else { return }
            
            // Advanced PD Math (Eye Center + Radius Projection)
            let leftEyeCenter = simd_make_float3(faceAnchor.leftEyeTransform.columns.3)
            let rightEyeCenter = simd_make_float3(faceAnchor.rightEyeTransform.columns.3)
            let leftEyeForward = simd_normalize(simd_make_float3(faceAnchor.leftEyeTransform.columns.2))
            let rightEyeForward = simd_normalize(simd_make_float3(faceAnchor.rightEyeTransform.columns.2))
            
            let eyeballRadius: Float = 0.012
            let leftPupilPos = leftEyeCenter + (leftEyeForward * eyeballRadius)
            let rightPupilPos = rightEyeCenter + (rightEyeForward * eyeballRadius)
            
            let distanceInMm = Double(simd_distance(leftPupilPos, rightPupilPos)) * 1000
            
            if distanceInMm > 45 && distanceInMm < 80 {
                pdMeasurements.append(distanceInMm)
                
                DispatchQueue.main.async {
                    self.parent.progress = CGFloat(self.pdMeasurements.count) / CGFloat(self.requiredFrames)
                }
                
                if pdMeasurements.count >= requiredFrames {
                    finishScanning(faceAnchor: faceAnchor)
                }
            }
        }
        
        func finishScanning(faceAnchor: ARFaceAnchor) {
            // Calculate final median PD
            let sorted = pdMeasurements.sorted()
            let medianPD = sorted[sorted.count / 2]
            
            DispatchQueue.main.async {
                // Haptic feedback
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                
                // Set the status to show the cool wireframe!
                self.parent.state = .processing
                self.parent.statusText = "Calculating..."
                
                // Populate results
                self.parent.results.pd = round(medianPD * 2) / 2
                
                // Transition to results sheet after 1.5 seconds of showing the mesh
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.parent.state = .results
                }
            }
        }
    }
}

// Helper to round specific corners of the bottom sheet
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
