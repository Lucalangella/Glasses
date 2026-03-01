import Foundation

@Observable
@MainActor
class ContentViewModel {

    // MARK: - Prescription State

    var prescription = Prescription()

    // MARK: - Scanner State

    var isShowingScanner = false

    // MARK: - Walkthrough State

    var isWalkthroughActive = false
    var walkthroughStep = 0
    var walkthroughStepCompleted = false

    var hasCompletedWalkthrough: Bool = UserDefaults.standard.bool(forKey: "hasCompletedWalkthrough") {
        didSet { UserDefaults.standard.set(hasCompletedWalkthrough, forKey: "hasCompletedWalkthrough") }
    }

    // MARK: - Walkthrough Steps

    let walkthroughSteps: [WalkthroughStep] = [
        WalkthroughStep(
            id: "sph",
            title: "Sphere (SPH)",
            body: "Tap SPH to open the ruler, then drag to set a value. This is the main power of your lens.",
            icon: "doc.text.fill",
            task: "Try it: tap SPH and drag the ruler to set a value",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "cyl",
            title: "Cylinder (CYL)",
            body: "CYL corrects astigmatism, an irregular curve in your cornea. If your prescription card shows 0.00 for CYL, you don't have astigmatism. Otherwise, tap CYL and set your value.",
            icon: "eye.fill",
            task: "Try it: tap CYL and drag the ruler to set a value",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "axis",
            title: "Cylinder Axis",
            body: "The axis (0\u{00B0}\u{2013}180\u{00B0}) tells exactly where to orient your cylinder correction. Tap AXIS to open the ruler and drag to match the number on your prescription card.",
            icon: "dial.low.fill",
            task: "Try it: tap AXIS and drag the ruler to set a value",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "pd_step",
            title: "Pupillary Distance",
            body: "PD is the distance between the centers of your pupils, in millimeters. It ensures your lenses are perfectly aligned. Type it in manually or tap the face icon to measure with AR.",
            icon: "faceid",
            task: "Try it: enter a PD value or measure with AR",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "lens_od",
            title: "Lens Thickness",
            body: "This shows how your prescription affects lens thickness. SE (spherical equivalent) is the sum of Sphere and Cylinder. A higher index (1.67, 1.74) makes lenses thinner and lighter. Try switching between the segments to compare.",
            icon: "cube.transparent.fill",
            task: "Try it: tap a different lens index to see the change",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "frames",
            title: "Frame Recommendations",
            body: "Clarity filters frames based on optical rules from your prescription. Tap any frame to see it in 3D or try it on your face with AR.",
            icon: "eyeglasses",
            task: nil,
            requiresCompletion: false
        )
    ]

    // MARK: - Recommendation Pass-throughs

    var recommendedFrames: Set<String>  { prescription.recommendedFrames }
    var recommendationReasons: [String] { prescription.recommendationReasons }
    var recommendationTitles: [String]  { prescription.recommendationTitles }
    var recommendationSummary: String   { prescription.recommendationSummary }

    // MARK: - Axis Helpers

    var odActiveAxis: Double { prescription.od.activeAxis }
    var osActiveAxis: Double { prescription.os.activeAxis }

    // MARK: - Sign Toggling

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

    // MARK: - Walkthrough Actions

    func resetWalkthrough() {
        walkthroughStep = 0
        walkthroughStepCompleted = false
    }

    func activateWalkthrough() {
        isWalkthroughActive = true
    }

    func completeWalkthrough() {
        hasCompletedWalkthrough = true
    }

    // MARK: - Walkthrough Step Completion

    func checkSphereCompletion(_ newValue: String) {
        guard isWalkthroughActive, walkthroughStep == 0 else { return }
        let val = Double(newValue.replacingOccurrences(of: "+", with: "")) ?? 0
        if abs(val) >= 0.25 {
            walkthroughStepCompleted = true
        }
    }

    func checkCylinderCompletion(_ newValue: String) {
        guard isWalkthroughActive, walkthroughStep == 1 else { return }
        let val = Double(newValue.replacingOccurrences(of: "+", with: "")) ?? 0
        if abs(val) >= 0.25 {
            walkthroughStepCompleted = true
        }
    }

    func checkAxisCompletion(old: String, new: String) {
        guard isWalkthroughActive, walkthroughStep == 2, old != new else { return }
        walkthroughStepCompleted = true
    }

    func checkPDCompletion(_ newValue: String) {
        guard isWalkthroughActive, walkthroughStep == 3 else { return }
        if let pdVal = Double(newValue), pdVal > 0 {
            walkthroughStepCompleted = true
        }
    }

    func handleLensIndexChanged() {
        guard isWalkthroughActive, walkthroughStep == 4 else { return }
        walkthroughStepCompleted = true
    }
}
