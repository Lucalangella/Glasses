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
                .id("lens_od")              
                                .walkthroughAnchor("lens_od")

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
            .onChange(of: selectedIndex) { _, _ in
                            NotificationCenter.default.post(name: .lensIndexChanged, object: nil)
                        }

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

    // 1. Lower the scaling factor to accommodate up to 20.00
    // 2. We use a non-linear scale (sqrt) so low powers aren't "invisible"
    //    while high powers don't clip.
    private var thicknessRatio: Double {
        let absPower = abs(power)
        guard absPower >= 0.12 else { return 0.05 }
        
        // Baseline: At 20.00 power, 1.50 index, we want roughly 90% height.
        // indexScale: High index (1.74) reduces thickness by ~30% compared to 1.50
        let indexScale = (1.50 - 1.0) / (refractiveIndex - 1.0)
        
        // Linear scale for 20.0 max: (absPower / 20.0) * indexScale
        // We'll cap it at 0.95 to leave a tiny margin
        return min((absPower / 20.0) * 0.9 * indexScale, 0.95)
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let W = rect.width
        let H = rect.height
        
        // Calculate dynamic thicknesses based on the frame height
        let maxT = H * thicknessRatio
        let minT = H * 0.1 // 10% height minimum for the thin part
        
        // Center the lens vertically
        let midY = H / 2.0

        if power < -0.12 {
            // MINUS: Thick edges, thin center
            // Total height at edges = maxT + minT
            let halfHeight = (maxT + minT) / 2
            let topY = midY - halfHeight
            let bottomEdgeY = midY + halfHeight
            let centerBottomY = topY + minT // The gap in the middle
            
            path.move(to: CGPoint(x: 0, y: topY))
            path.addLine(to: CGPoint(x: W, y: topY))
            path.addLine(to: CGPoint(x: W, y: bottomEdgeY))
            path.addQuadCurve(
                to: CGPoint(x: 0, y: bottomEdgeY),
                control: CGPoint(x: W/2, y: centerBottomY)
            )
            path.closeSubpath()

        } else if power > 0.12 {
            // PLUS: Thin edges, thick center
            let halfHeight = (maxT + minT) / 2
            let edgeTopY = midY - (minT / 2)
            let edgeBottomY = midY + (minT / 2)
            let centerTopY = midY - halfHeight
            
            path.move(to: CGPoint(x: 0, y: edgeTopY))
            path.addQuadCurve(
                to: CGPoint(x: W, y: edgeTopY),
                control: CGPoint(x: W/2, y: centerTopY)
            )
            path.addLine(to: CGPoint(x: W, y: edgeBottomY))
            path.addLine(to: CGPoint(x: 0, y: edgeBottomY))
            path.closeSubpath()
            
        } else {
            // PLANO
            let pHeight = H * 0.1
            path.addRect(CGRect(x: 0, y: midY - pHeight/2, width: W, height: pHeight))
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
