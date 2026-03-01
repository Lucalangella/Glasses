import Foundation

enum EyeLensIndex: String, CaseIterable {
    case poly = "1.59"
    case mid  = "1.67"
    case high = "1.74"

    var label: String { rawValue }

    var refractiveIndex: Double {
        switch self {
        case .poly: return 1.59
        case .mid:  return 1.67
        case .high: return 1.74
        }
    }
}
