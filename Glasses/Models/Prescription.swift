import Foundation

// MARK: - Eye Data

struct EyeData {
    var sphere: String = ""
    var cylinder: String = ""
    var axis: String = ""

    var sphereValue: Double {
        Double(sphere.replacingOccurrences(of: "+", with: "")) ?? 0
    }

    var cylinderValue: Double {
        Double(cylinder.replacingOccurrences(of: "+", with: "")) ?? 0
    }

    /// Spherical equivalent: the single-number summary of total lens power.
    var sphericalEquivalent: Double {
        sphereValue + cylinderValue / 2.0
    }

    var activeAxis: Double {
        if let val = Double(axis) { return val }
        return 0
    }
}

// MARK: - Optical Rule

/// A single clinical reason that influenced the recommendation.
struct OpticalRule {
    /// Short label shown in the header chip, e.g. "High Rx"
    let title: String
    /// Plain-English sentence for the info blurb, e.g. "your prescription reaches -7.50"
    let reason: String
    /// The set of frames this rule removes from the full catalogue
    let framesToExclude: Set<String>
}

// MARK: - Prescription

struct Prescription {
    var od: EyeData = EyeData()
    var os: EyeData = EyeData()
    var pd: String = ""

    // ─────────────────────────────────────────────
    // MARK: Derived values
    // ─────────────────────────────────────────────

    private var pdValue: Double? {
        guard let v = Double(pd), v > 0 else { return nil }
        return v
    }

    /// The stronger spherical equivalent across both eyes.
    private var dominantSE: Double {
        [od.sphericalEquivalent, os.sphericalEquivalent]
            .max(by: { abs($0) < abs($1) }) ?? 0
    }

    /// Absolute difference in SE between eyes (anisometropia).
    private var anisometropiaAmount: Double {
        abs(od.sphericalEquivalent - os.sphericalEquivalent)
    }

    /// The stronger CYL magnitude across both eyes.
    private var dominantCylinder: Double {
        max(abs(od.cylinderValue), abs(os.cylinderValue))
    }

    // ─────────────────────────────────────────────
    // MARK: Clinical Rules
    // ─────────────────────────────────────────────

    /// All optical rules currently triggered by the entered prescription.
    var activeRules: [OpticalRule] {
        var rules: [OpticalRule] = []

        // Rule 1 – High Rx (4.00 D ≤ |SE| < 7.00 D)
        // Larger lens blanks dramatically increase edge thickness on minus lenses
        // and centre thickness on plus lenses. Only small, curved frames minimise this.
        // • Browline excluded: semi-rimless bottom exposes the thick edge
        // • Cat-eye excluded: asymmetric corners create uneven edge thickness
        // • Rectangle & square excluded: flat edges and sharp corners accumulate thickness
        // • Geometric excluded: large angular surface area, unpredictable edges
        // • Aviator & oversized excluded: large deep shapes, worst case for blank size
        if abs(dominantSE) >= 4.0 && abs(dominantSE) < 7.0 {
            let type = dominantSE < 0 ? "myopia" : "hyperopia"
            rules.append(OpticalRule(
                title: "High Rx",
                reason: "your prescription reaches \(String(format: "%+.2f", dominantSE)) (\(type))",
                framesToExclude: ["aviator", "browline", "cateye", "geometric",
                                  "oversized", "rectangle", "square"]
            ))
        }

        // Rule 2 – Very High Rx (|SE| ≥ 7.00 D)
        // Round is the clinical gold standard — uniform edge thickness all the way
        // around, easiest to disguise with a rolled/polished edge finish.
        // Oval is retained as the only acceptable alternative.
        // All other frames excluded for the same reasons as Rule 1, now unconditionally.
        if abs(dominantSE) >= 7.0 {
            let type = dominantSE < 0 ? "myopia" : "hyperopia"
            rules.append(OpticalRule(
                title: "Very High Rx",
                reason: "your prescription is very strong (\(String(format: "%+.2f", dominantSE)) \(type))",
                framesToExclude: ["aviator", "browline", "cateye", "geometric",
                                  "oversized", "rectangle", "square"]
            ))
        }

        // Rule 3 – Narrow PD (< 58 mm)
        // Wide frames force heavy decentration of the optical centres,
        // introducing unwanted prism and eyestrain.
        // • Square excluded as borderline-wide with sharp corners
        if let pd = pdValue, pd < 58.0 {
            rules.append(OpticalRule(
                title: "Narrow PD",
                reason: "your PD is narrow (\(String(format: "%.1f", pd)) mm)",
                framesToExclude: ["aviator", "browline", "oversized", "square"]
            ))
        }

        // Rule 4 – Wide PD (> 70 mm)
        // Narrow frames can't place optical centres far enough apart,
        // causing base-in prism, convergence stress, and diplopia.
        // • Cat-eye excluded: optical centre sits narrow despite the wide outer top
        // • Oval & round excluded: too narrow horizontally for a wide PD
        if let pd = pdValue, pd > 70.0 {
            rules.append(OpticalRule(
                title: "Wide PD",
                reason: "your PD is wide (\(String(format: "%.1f", pd)) mm)",
                framesToExclude: ["cateye", "oval", "round"]
            ))
        }

        // Rule 5 – Significant astigmatism (|CYL| ≥ 2.00 D)
        // Pantoscopic tilt and face-form wrap rotate the effective cylinder axis,
        // degrading the correction. Deep and wrapped frames are the main risk.
        // • Rectangle & square kept: flat and stable, actually good for astigmatism
        // • Browline kept: relatively flat and stable
        // • Geometric excluded: angular cuts introduce unpredictable tilt
        if dominantCylinder >= 2.0 {
            rules.append(OpticalRule(
                title: "Astigmatism",
                reason: "your cylinder correction is significant (\(String(format: "%.2f", dominantCylinder)) D)",
                framesToExclude: ["aviator", "cateye", "geometric", "oversized"]
            ))
        }

        // Rule 6 – Anisometropia (≥ 2.00 D difference between eyes)
        // Significantly different lens thicknesses are best hidden by full-rim frames.
        // • Aviator excluded: rimless bottom exposes the edge difference
        // • Browline excluded: semi-rimless bottom exposes the edge difference
        // • Oversized excluded: large surface amplifies the visible thickness difference
        if anisometropiaAmount >= 2.0 {
            rules.append(OpticalRule(
                title: "Anisometropia",
                reason: "there's a notable power difference between your eyes (\(String(format: "%.2f", anisometropiaAmount)) D)",
                framesToExclude: ["aviator", "browline", "oversized"]
            ))
        }

        return rules
    }

    // ─────────────────────────────────────────────
    // MARK: Recommended Frames
    // ─────────────────────────────────────────────

    private static let allFrames: Set<String> = [
        "aviator", "browline", "cateye",
        "geometric", "oval", "oversized",
        "rectangle", "round", "square"
    ]

    /// Frames that pass all active clinical rules.
    /// Returns all frames when no rules are triggered — every style is suitable.
    var recommendedFrames: Set<String> {
        guard !activeRules.isEmpty else { return Prescription.allFrames }

        let excluded = activeRules.reduce(Set<String>()) { $0.union($1.framesToExclude) }
        let recommended = Prescription.allFrames.subtracting(excluded)

        // Safety net: if every frame is excluded (extreme edge case),
        // round is always the safest optical choice.
        return recommended.isEmpty ? ["round"] : recommended
    }

    // ─────────────────────────────────────────────
    // MARK: UI helpers
    // ─────────────────────────────────────────────

    /// Plain-text reasons for the info blurb, one per active rule.
    var recommendationReasons: [String] {
        activeRules.map(\.reason)
    }

    /// Short chip labels, e.g. ["High Rx", "Narrow PD"]
    var recommendationTitles: [String] {
        activeRules.map(\.title)
    }

    /// A single grammatically correct sentence summarising all active rules,
    /// or a positive message when no rules are triggered.
    var recommendationSummary: String {
        guard !activeRules.isEmpty else {
            return "Any frame style will work well for you. Every shape here is a great choice. Pick whatever you love."
        }

        let reasons = activeRules.map(\.reason)

        let reasonsString: String
        if reasons.count == 1 {
            reasonsString = reasons[0]
        } else {
            let allButLast = reasons.dropLast().joined(separator: ", ")
            reasonsString = "\(allButLast) and \(reasons.last!)"
        }

        return "Based on \(reasonsString), these frames are curated to optimise your visual clarity and minimise lens edge thickness."
    }

    // ─────────────────────────────────────────────
    // MARK: Legacy compatibility
    // ─────────────────────────────────────────────

    var maxPowerString: String? {
        guard abs(dominantSE) >= 4.0 else { return nil }
        return String(format: "%+.2f", dominantSE)
    }

    var narrowPDValue: Double? {
        guard let pd = pdValue, pd < 58.0 else { return nil }
        return pd
    }
}
