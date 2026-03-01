import Foundation
import ARKit

@Observable
@MainActor
class FaceScannerViewModel {
    var state: ScanState = .intro
    var progress: CGFloat = 0.0
    var statusText: String = ""
    var scanResults = FaceScanResults()

    private var pdMeasurements: [Double] = []
    private let requiredFrames: Int = 60

    private var hasTriggeredFollowDotTimer: Bool = false

    func startScan() {
        pdMeasurements.removeAll()
        progress = 0.0
        hasTriggeredFollowDotTimer = false

        state = .focusCenter
        statusText = "Focus on this dot. When it moves follow it."
    }

    func resetScan() {
        startScan()
    }

    func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        let lookAtPoint = faceAnchor.lookAtPoint

        let isLookingAtPhone = abs(lookAtPoint.x) < 0.2 && abs(lookAtPoint.y) < 0.2

        switch state {
        case .focusCenter:
            if isLookingAtPhone {
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    if self.state == .focusCenter {
                        self.state = .followDot
                        self.statusText = "Look here."
                    }
                }
            }

        case .followDot:
            if !hasTriggeredFollowDotTimer {
                hasTriggeredFollowDotTimer = true

                Task {
                    try? await Task.sleep(for: .seconds(2.0))
                    if self.state == .followDot {
                        self.state = .measuring
                        self.statusText = "Measuring."
                    }
                }
            }

        case .measuring:
            if isLookingAtPhone {
                statusText = "Measuring."
                let distanceInMm = PDCalculator.calculateDistance(from: faceAnchor)

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

        state = .processing
        statusText = "Complete!"
        scanResults.pd = finalPD

        Task {
            try? await Task.sleep(for: .seconds(1.5))
            self.state = .results
        }
    }
}
