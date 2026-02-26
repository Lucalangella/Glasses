//
//  PDCalculator.swift
//  Glasses
//
//  Created by Luca Langella 1 on 2/26/26.
//

import ARKit
import simd

struct PDCalculator {
    // Average human eyeball radius in meters
    private static let eyeballRadius: Float = 0.012

    /// Calculates the raw distance between pupils in millimeters from an ARFaceAnchor
    static func calculateDistance(from faceAnchor: ARFaceAnchor) -> Double {
        let leftEyeCenter = simd_make_float3(faceAnchor.leftEyeTransform.columns.3)
        let rightEyeCenter = simd_make_float3(faceAnchor.rightEyeTransform.columns.3)
        
        let leftEyeForward = simd_normalize(simd_make_float3(faceAnchor.leftEyeTransform.columns.2))
        let rightEyeForward = simd_normalize(simd_make_float3(faceAnchor.rightEyeTransform.columns.2))
        
        let leftPupilPos = leftEyeCenter + (leftEyeForward * eyeballRadius)
        let rightPupilPos = rightEyeCenter + (rightEyeForward * eyeballRadius)
        
        let distanceInMeters = simd_distance(leftPupilPos, rightPupilPos)
        return Double(distanceInMeters * 1000)
    }
    
    /// Finds the median measurement and rounds to the nearest 0.5mm
    static func processFinalPD(from measurements: [Double]) -> Double {
        guard !measurements.isEmpty else { return 0.0 }
        let sorted = measurements.sorted()
        let median = sorted[sorted.count / 2]
        return round(median * 2) / 2
    }
}
