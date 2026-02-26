import SwiftUI

// MARK: - Main View

struct LensVisualizationView: View {
    @Binding var prescription: Prescription

    var body: some View {
        VStack(spacing: 0) {
            Text("Lens Thickness")
                .font(.title2.weight(.bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

            HStack(spacing: 16) {
                EyeLensCard(
                    eyeLabel: "OD",
                    eyeSubtitle: "Right Eye",
                    sphere: prescription.od.sphere,
                    cylinder: prescription.od.cylinder
                )

                EyeLensCard(
                    eyeLabel: "OS",
                    eyeSubtitle: "Left Eye",
                    sphere: prescription.os.sphere,
                    cylinder: prescription.os.cylinder
                )
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Eye Lens Card

struct EyeLensCard: View {
    let eyeLabel: String
    let eyeSubtitle: String
    let sphere: String
    let cylinder: String

    @State private var selectedIndex: EyeLensIndex = .poly

    private var sphericalEquivalent: Double {
        let sph = Double(sphere.replacingOccurrences(of: "+", with: "")) ?? 0
        let cyl = Double(cylinder.replacingOccurrences(of: "+", with: "")) ?? 0
        return sph + cyl / 2.0
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(eyeLabel)
                        .font(.title3.weight(.bold))
                    Text(eyeSubtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if abs(sphericalEquivalent) >= 0.25 {
                    Text(String(format: "%+.2f SE", sphericalEquivalent))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.12))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, 10)

            // Segmented index picker
            Picker("Lens Index", selection: $selectedIndex) {
                ForEach(EyeLensIndex.allCases, id: \.self) { idx in
                    Text(idx.label).tag(idx)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 16)
            .padding(.bottom, 14)

            // Lens cross-section
            LensCrossSectionView(
                power: sphericalEquivalent,
                refractiveIndex: selectedIndex.refractiveIndex
            )
            .frame(height: 110)
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.07), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Lens Index Options

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

// MARK: - Lens Cross Section View

struct LensCrossSectionView: View {
    let power: Double
    let refractiveIndex: Double

    /// Colour matching the reference chart blue.
    private let lensColor = Color(red: 0.45, green: 0.63, blue: 0.82)

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Filled lens body
                LensCrossSectionShape(power: power, refractiveIndex: refractiveIndex)
                    .fill(
                        LinearGradient(
                            colors: [lensColor.opacity(0.95), lensColor.opacity(0.75)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Subtle top highlight for a glassy feel
                LensCrossSectionShape(power: power, refractiveIndex: refractiveIndex)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.18), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )

                // Outline
                LensCrossSectionShape(power: power, refractiveIndex: refractiveIndex)
                    .stroke(lensColor.opacity(0.9), lineWidth: 1.2)
            }
        }
    }
}

// MARK: - Lens Cross Section Shape

struct LensCrossSectionShape: Shape {
    let power: Double
    let refractiveIndex: Double

    /// Fraction of the display height that the maximum thickness occupies.
    /// Scales with power and is reduced for higher refractive indices (physics-based).
    private var thicknessRatio: Double {
        guard abs(power) >= 0.25 else { return 0.0 }
        // t ∝ 1/(n-1), normalised to 1.59 as the baseline
        let indexScale = 0.59 / (refractiveIndex - 1.0)
        return min(abs(power) * 0.082 * indexScale, 0.88)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()

        let W    = rect.width
        let H    = rect.height
        let midX = W / 2.0
        let midY = H / 2.0

        // Max thickness in pixels
        let maxT: CGFloat = H * thicknessRatio
        // Min (center) thickness — always a thin visible sliver
        let minT: CGFloat = max(H * 0.08, 7)

        if power < -0.25 {
            // ── MINUS LENS ────────────────────────────────────────────────
            // Flat top surface; concave (rising) bottom surface.
            // Edges are thick (maxT), center is thin (minT).

            let effectiveMaxT = max(maxT, minT + H * 0.06)
            let topY          = midY - effectiveMaxT / 2     // flat top (centered)
            let bottomEdgeY   = midY + effectiveMaxT / 2     // bottom at edges
            let centerBottomY = bottomEdgeY - (effectiveMaxT - minT) // concave bottom rises at center

            path.move(to: CGPoint(x: 0, y: topY))
            path.addLine(to: CGPoint(x: W, y: topY))              // flat top
            path.addLine(to: CGPoint(x: W, y: bottomEdgeY))       // right edge down
            path.addQuadCurve(                                      // concave bottom
                to: CGPoint(x: 0, y: bottomEdgeY),
                control: CGPoint(x: midX, y: centerBottomY)
            )
            path.closeSubpath()

        } else if power > 0.25 {
            // ── PLUS LENS ─────────────────────────────────────────────────
            // Convex (rising) top surface; flat bottom surface.
            // Center is thick (maxT), edges are thin (minT).

            let effectiveMaxT = max(maxT, minT + H * 0.06)
            let topEdgeY   = midY - minT / 2                 // top at edges (centered)
            let centerTopY = midY - effectiveMaxT / 2        // top at center (highest point)
            let bottomY    = midY + effectiveMaxT / 2        // flat bottom

            path.move(to: CGPoint(x: 0, y: topEdgeY))
            path.addQuadCurve(                                      // convex top
                to: CGPoint(x: W, y: topEdgeY),
                control: CGPoint(x: midX, y: centerTopY)
            )
            path.addLine(to: CGPoint(x: W, y: bottomY))            // right edge down
            path.addLine(to: CGPoint(x: 0, y: bottomY))            // flat bottom
            path.closeSubpath()

        } else {
            // ── PLANO ─────────────────────────────────────────────────────
            let thickness: CGFloat = max(H * 0.09, 7)
            path.addRect(CGRect(x: 0, y: midY - thickness / 2, width: W, height: thickness))
        }

        return path
    }
}

// MARK: - Preview

#Preview {
    LensVisualizationView(prescription: .constant(Prescription(
        od: EyeData(sphere: "-6.00", cylinder: "-1.50", axis: "90"),
        os: EyeData(sphere: "+4.00", cylinder: "-0.75", axis: "85"),
        pd: "63.0"
    )))
    .background(Color(UIColor.systemGroupedBackground))
}
