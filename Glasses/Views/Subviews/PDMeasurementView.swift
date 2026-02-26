
import SwiftUI
import ARKit
import RealityKit

struct PDMeasurementView: View {
    @Binding var isPresented: Bool
    @Binding var pdValue: String
    
    @State private var progress: CGFloat = 0.0
    // FIX 1: Update instructions to be explicit about glasses
    @State private var instructions = "Remove glasses and look at the Camera Lens."
    
    var body: some View {
        ZStack {
            // AR Camera Background
            ARFaceMeasurementView(progress: $progress, pdValue: $pdValue) {
                // On Completion
                UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
                instructions = "Measurement Complete!"
                
                // Dismiss after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    isPresented = false
                }
            }
            .ignoresSafeArea()
            
            // Scanner OverlayContainer
            VStack(spacing: 24) {
                // Close Button Header
                HStack {
                    Spacer()
                    Button(action: { isPresented = false }) {
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
                
                // Center Guides
                ZStack {
                    // The Face Outline Guide
                    Ellipse()
                        .stroke(style: StrokeStyle(lineWidth: 4, dash: [12, 12]))
                        // Turn green when scanning starts
                        .foregroundColor(progress > 0 ? .green.opacity(0.8) : .white.opacity(0.4))
                        .frame(width: 240, height: 340)
                        .animation(.easeInOut(duration: 0.3), value: progress > 0)
                    
                    // The Progress Ring
                    Ellipse()
                        .trim(from: 0, to: progress)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                        .frame(width: 240, height: 340)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: progress)
                    
                    // FIX 2: Add a prominent "Remove Glasses" icon before scanning starts
                    if progress == 0 {
                        VStack(spacing: 12) {
                            ZStack {
                                Image(systemName: "eyeglasses")
                                    .font(.system(size: 50))
                                    .foregroundColor(.white.opacity(0.8))
                                
                                Image(systemName: "xmark")
                                    .font(.system(size: 30, weight: .bold))
                                    .foregroundColor(.red.opacity(0.9))
                                    .offset(y: -2)
                            }
                        }
                        .transition(.opacity)
                    }
                }
                
                Spacer()
                
                // Instruction Panel
                Text(instructions)
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 24)
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .cornerRadius(16)
                    .padding(.bottom, 50)
                    // Use an ID to force a smooth transition when text changes
                    .id(instructions)
                    .transition(.push(from: .bottom).combined(with: .opacity))
                    .animation(.easeInOut, value: instructions)
            }
        }
    }
}

// (Keep your existing ARFaceMeasurementView struct and Coordinator class below this unchanged)

struct ARFaceMeasurementView: UIViewRepresentable {
    @Binding var progress: CGFloat
    @Binding var pdValue: String
    var onComplete: () -> Void
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        arView.session.delegate = context.coordinator
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return arView
        }
        
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ARSessionDelegate {
            var parent: ARFaceMeasurementView
            var measurements: [Float] = []
            let requiredFrames: Int = 45 // Slightly more frames for a better median sample (~0.75 seconds)
            var isDone = false
            
            // Average human eyeball radius in meters
            let eyeballRadius: Float = 0.012
            
            init(_ parent: ARFaceMeasurementView) {
                self.parent = parent
            }
            
            func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
                guard !isDone, let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
                
                // 1. Get the center position of both eyeballs (Column 3)
                let leftEyeCenter = simd_make_float3(faceAnchor.leftEyeTransform.columns.3)
                let rightEyeCenter = simd_make_float3(faceAnchor.rightEyeTransform.columns.3)
                
                // 2. Get the forward-pointing vector of the eyes (Column 2 is the Z-axis in ARKit)
                let leftEyeForward = simd_normalize(simd_make_float3(faceAnchor.leftEyeTransform.columns.2))
                let rightEyeForward = simd_normalize(simd_make_float3(faceAnchor.rightEyeTransform.columns.2))
                
                // 3. Project forward by the radius of the eyeball to find the actual pupil surface
                let leftPupilPos = leftEyeCenter + (leftEyeForward * eyeballRadius)
                let rightPupilPos = rightEyeCenter + (rightEyeForward * eyeballRadius)
                
                // Calculate Euclidean distance in meters, convert to mm
                let distanceInMeters = simd_distance(leftPupilPos, rightPupilPos)
                let distanceInMm = distanceInMeters * 1000
                
                // Filter out biological impossibilities (Normal adult PD is ~54mm to ~74mm)
                if distanceInMm > 45 && distanceInMm < 80 {
                    measurements.append(distanceInMm)
                    
                    DispatchQueue.main.async {
                        self.parent.progress = CGFloat(self.measurements.count) / CGFloat(self.requiredFrames)
                    }
                    
                    if measurements.count >= requiredFrames {
                        isDone = true
                        
                        // 4. STATISTICAL UPGRADE: Use the Median instead of Mean to drop glitches
                        let sortedMeasurements = measurements.sorted()
                        let medianPD = sortedMeasurements[sortedMeasurements.count / 2]
                        
                        DispatchQueue.main.async {
                            // Standard optometry rounds to the nearest 0.5 mm
                            let roundedPD = round(medianPD * 2) / 2
                            self.parent.pdValue = String(format: "%.1f", roundedPD)
                            self.parent.onComplete()
                        }
                    }
                }
            }
        }
}

