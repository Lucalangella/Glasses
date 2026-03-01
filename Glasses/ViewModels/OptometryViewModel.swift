import Foundation
import SwiftUI
import Combine

class OptometryViewModel: ObservableObject {
    @Published var prescription: Prescription = Prescription()

    // MARK: - Recommendation pass-throughs

    var recommendedFrames: Set<String>      { prescription.recommendedFrames }
    var recommendationReasons: [String]     { prescription.recommendationReasons }
    var recommendationTitles: [String]      { prescription.recommendationTitles }   // NEW
    var recommendationSummary: String       { prescription.recommendationSummary }

    // MARK: - Axis helpers

    var odActiveAxis: Double { prescription.od.activeAxis }
    var osActiveAxis: Double { prescription.os.activeAxis }

    // MARK: - Sign toggling

    func toggleSign(eye: EyeType, field: FieldType) {
        switch eye {
        case .od: updateField(field: field, data: &prescription.od)
        case .os: updateField(field: field, data: &prescription.os)
        }
    }

    private func updateField(field: FieldType, data: inout EyeData) {
        switch field {
        case .sphere:   data.sphere   = toggleSign(value: data.sphere)
        case .cylinder: data.cylinder = toggleSign(value: data.cylinder)
        }
    }

    private func toggleSign(value: String) -> String {
        var currentText = value
        if currentText.hasPrefix("+") {
            currentText.removeFirst()
            return "-" + currentText
        } else if currentText.hasPrefix("-") {
            currentText.removeFirst()
            return "+" + currentText
        } else if !currentText.isEmpty {
            return "+" + currentText
        } else {
            return "+"
        }
    }

    enum EyeType  { case od, os }
    enum FieldType { case sphere, cylinder }
}
