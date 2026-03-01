import Foundation

// MARK: - Scan State

enum ScanState {
    case intro
    case focusCenter
    case followDot
    case measuring
    case processing
    case results
}

// MARK: - Scan Results

struct FaceScanResults {
    var pd: Double = 0.0
}
