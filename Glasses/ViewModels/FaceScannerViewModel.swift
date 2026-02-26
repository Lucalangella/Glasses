//
//  FaceScannerViewModel.swift
//  Glasses
//
//  Created by Luca Langella 1 on 2/26/26.
//

import SwiftUI
import ARKit
import Combine

enum ScanState {
    case intro
    case scanning
    case processing
    case results
}

struct FaceScanResults {
    var pd: Double = 0.0
}

class FaceScannerViewModel: ObservableObject {
    @Published var state: ScanState = .intro
    @Published var progress: CGFloat = 0.0
    @Published var statusText: String = "Measuring"
    @Published var scanResults = FaceScanResults()
    
    // We can move the measurement array and logic here!
    private var pdMeasurements: [Double] = []
    private let requiredFrames: Int = 60
    
    func startScan() {
        state = .scanning
        progress = 0.0
        pdMeasurements.removeAll()
    }
    
    func resetScan() {
        startScan()
    }
    
    // The ViewModel processes the anchor, not the View!
    func processFaceAnchor(_ faceAnchor: ARFaceAnchor) {
        guard state == .scanning else { return }
        
        let lookAtPoint = faceAnchor.lookAtPoint
        let isLookingAtCamera = abs(lookAtPoint.x) < 0.1 && abs(lookAtPoint.y) < 0.1
        
        statusText = isLookingAtCamera ? "Measuring" : "Look forward and hold still"
        guard isLookingAtCamera else { return }
        
        let distanceInMm = PDCalculator.calculateDistance(from: faceAnchor)
        
        if distanceInMm > 45 && distanceInMm < 80 {
            pdMeasurements.append(distanceInMm)
            progress = CGFloat(pdMeasurements.count) / CGFloat(requiredFrames)
            
            if pdMeasurements.count >= requiredFrames {
                finishScanning()
            }
        }
    }
    
    private func finishScanning() {
        let finalPD = PDCalculator.processFinalPD(from: pdMeasurements)
        
        // Trigger haptics from the ViewModel!
        UIImpactFeedbackGenerator(style: .heavy).impactOccurred()
        
        state = .processing
        statusText = "Calculating..."
        scanResults.pd = finalPD
        
        // Transition to results sheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.state = .results
        }
    }
}
