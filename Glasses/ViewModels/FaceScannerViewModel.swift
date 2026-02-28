import SwiftUI
import ARKit
import Combine

enum ScanState {
    case intro
    case focusCenter
    case followDot
    case measuring
    case processing
    case results
}

struct FaceScanResults {
    var pd: Double = 0.0
}

class FaceScannerViewModel: ObservableObject {
    @Published var state: ScanState = .intro
    @Published var progress: CGFloat = 0.0
    @Published var statusText: String = ""
    @Published var scanResults = FaceScanResults()
    
    private var pdMeasurements: [Double] = []
    private let requiredFrames: Int = 60
    
    // Flags to prevent triggering timers multiple times
    private var hasTriggeredFollowDotTimer: Bool = false
    
    func startScan() {
        pdMeasurements.removeAll()
        progress = 0.0
        hasTriggeredFollowDotTimer = false
        
        // Step 1: Initial Focus State
        state = .focusCenter
        statusText = "Focus on this dot. When it moves follow it."
    }
    
    func resetScan() {
        startScan()
    }
    
    func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        let lookAtPoint = faceAnchor.lookAtPoint
        
        // A forgiving check: are they generally looking towards the phone?
        let isLookingAtPhone = abs(lookAtPoint.x) < 0.2 && abs(lookAtPoint.y) < 0.2
        
        switch state {
        case .focusCenter:
            if isLookingAtPhone {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    if self.state == .focusCenter {
                        self.state = .followDot
                        self.statusText = "Look here."
                    }
                }
            }
            
        case .followDot:
            // Since users might tilt their head instead of moving their eyes,
            // we give them 2 seconds to follow the dot to the camera lens naturally.
            if !hasTriggeredFollowDotTimer {
                hasTriggeredFollowDotTimer = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    if self.state == .followDot {
                        self.state = .measuring
                        self.statusText = "Measuring."
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
                }
            }
            
        case .measuring:
            if isLookingAtPhone {
                statusText = "Measuring."
                let distanceInMm = PDCalculator.calculateDistance(from: faceAnchor)
                
                // Normal human PD range
                if distanceInMm > 45 && distanceInMm < 80 {
                    pdMeasurements.append(distanceInMm)
                    progress = CGFloat(pdMeasurements.count) / CGFloat(requiredFrames)
                    
                    if pdMeasurements.count >= requiredFrames {
                        finishScanning()
                    }
                }
            } else {
                statusText = "Keep looking at the dot."
            }
            
        case .intro, .processing, .results:
            break
        }
    }
    
    private func finishScanning() {
            let finalPD = PDCalculator.processFinalPD(from: pdMeasurements)
            UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
            
            state = .processing
            statusText = "Complete!"
            scanResults.pd = finalPD
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.state = .results
            }
        }
}
