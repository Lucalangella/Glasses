import SwiftUI
import ARKit
import RealityKit

struct PDMeasurementView: View {
    @Binding var isPresented: Bool
    @Binding var pdValue: String
    
    @State private var progress: CGFloat = 0.0
    @State private var instructions = "Look directly at the Camera Lens." // Text updated here
    
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
                    
                    // Removed the crossed-out glasses icon from here
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
        
        // Note: Switched to Double to match the PDCalculator output
        var measurements: [Double] = []
        let requiredFrames: Int = 45 // Takes ~0.75 seconds to collect
        var isDone = false
        
        init(_ parent: ARFaceMeasurementView) {
            self.parent = parent
        }
        
        func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
            // Find the first face anchor, exit if we are already done
            guard !isDone, let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
            
            // 1. Calculate the distance using our extracted utility
            let distanceInMm = PDCalculator.calculateDistance(from: faceAnchor)
            
            // 2. Filter out biological impossibilities (Normal adult PD is ~54mm to ~74mm)
            if distanceInMm > 45 && distanceInMm < 80 {
                measurements.append(distanceInMm)
                
                // Update the progress ring on the main thread
                DispatchQueue.main.async {
                    self.parent.progress = CGFloat(self.measurements.count) / CGFloat(self.requiredFrames)
                }
                
                // 3. Once we have enough frames, process the final result
                if measurements.count >= requiredFrames {
                    isDone = true
                    
                    // Let the utility handle the sorting and median math
                    let finalPD = PDCalculator.processFinalPD(from: measurements)
                    
                    DispatchQueue.main.async {
                        self.parent.pdValue = String(format: "%.1f", finalPD)
                        self.parent.onComplete()
                    }
                }
            }
        }
    }
}

