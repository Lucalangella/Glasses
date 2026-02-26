import SwiftUI

struct LensSelectionView: View {
    @Binding var prescription: Prescription
    @State private var selectedIndex: LensIndex = .standard
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                VStack(spacing: 8) {
                    Text("Lens Materials & Index")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Choose the right lens material for your prescription")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                // Recommendation Card
                if let recommendation = lensRecommendation {
                    RecommendationCard(
                        recommendation: recommendation,
                        prescriptionStrength: maxAbsPower
                    )
                    .padding(.horizontal)
                }
                
                // Material Comparison
                MaterialComparisonView(
                    selectedIndex: $selectedIndex,
                    prescriptionStrength: maxAbsPower
                )
                .padding(.horizontal)
                
                // Thickness Visualization
                ThicknessVisualizationView(
                    prescriptionStrength: maxAbsPower,
                    selectedIndex: selectedIndex
                )
                .padding(.horizontal)
                
                // Material Details Cards
                VStack(spacing: 16) {
                    ForEach(LensIndex.allCases, id: \.self) { index in
                        MaterialDetailCard(
                            lensIndex: index,
                            isSelected: selectedIndex == index,
                            prescriptionStrength: maxAbsPower
                        )
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3)) {
                                selectedIndex = index
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Coatings Navigation
                NavigationLink(destination: LensCoatingsView()) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Add Lens Coatings")
                                .font(.headline)
                            
                            Text("Protect and enhance your lenses")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.1), Color.purple.opacity(0.1)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Lens Selection")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Computed Properties
    
    private var maxAbsPower: Double {
        let odSph = Double(prescription.od.sphere.replacingOccurrences(of: "+", with: "")) ?? 0
        let odCyl = Double(prescription.od.cylinder.replacingOccurrences(of: "+", with: "")) ?? 0
        let osSph = Double(prescription.os.sphere.replacingOccurrences(of: "+", with: "")) ?? 0
        let osCyl = Double(prescription.os.cylinder.replacingOccurrences(of: "+", with: "")) ?? 0
        
        let odMax = abs(odSph) > abs(odSph + odCyl) ? abs(odSph) : abs(odSph + odCyl)
        let osMax = abs(osSph) > abs(osSph + osCyl) ? abs(osSph) : abs(osSph + osCyl)
        
        return max(odMax, osMax)
    }
    
    private var lensRecommendation: LensRecommendation? {
        LensRecommendation.getRecommendation(for: maxAbsPower)
    }
}

// MARK: - Lens Index Enum

enum LensIndex: String, CaseIterable {
    case standard = "1.59 Polycarbonate"
    case midIndex = "1.67 Index"
    case highIndex = "1.74 Index"
    
    var indexValue: Double {
        switch self {
        case .standard: return 1.59
        case .midIndex: return 1.67
        case .highIndex: return 1.74
        }
    }
    
    var benefits: [String] {
        switch self {
        case .standard:
            return [
                "Impact resistant",
                "Built-in UV protection",
                "Lightweight",
                "Affordable"
            ]
        case .midIndex:
            return [
                "30% thinner than standard",
                "UV protection",
                "Good for moderate prescriptions",
                "Balanced cost & performance"
            ]
        case .highIndex:
            return [
                "Up to 50% thinner",
                "Lightest option",
                "Best for strong prescriptions",
                "Premium aesthetics"
            ]
        }
    }
    
    var icon: String {
        switch self {
        case .standard: return "shield.fill"
        case .midIndex: return "circle.hexagongrid.fill"
        case .highIndex: return "sparkles"
        }
    }
    
    var color: Color {
        switch self {
        case .standard: return .blue
        case .midIndex: return .purple
        case .highIndex: return .pink
        }
    }
    
    // Relative thickness multiplier (1.0 = thickest)
    func thicknessMultiplier(for power: Double) -> Double {
        let baseThickness = abs(power) * 0.15 // Simplified calculation
        return baseThickness / indexValue
    }
}

// MARK: - Lens Recommendation

struct LensRecommendation {
    let recommendedIndex: LensIndex
    let reason: String
    let thicknessSavings: String
    
    static func getRecommendation(for power: Double) -> LensRecommendation? {
        let absPower = abs(power)
        
        if absPower < 2.0 {
            return LensRecommendation(
                recommendedIndex: .standard,
                reason: "Your prescription is low, standard lenses will work great",
                thicknessSavings: "Standard thickness is already minimal"
            )
        } else if absPower < 4.0 {
            return LensRecommendation(
                recommendedIndex: .midIndex,
                reason: "1.67 lenses will be noticeably thinner and lighter",
                thicknessSavings: "~30% thinner than standard"
            )
        } else if absPower < 6.0 {
            return LensRecommendation(
                recommendedIndex: .highIndex,
                reason: "High-index lenses are recommended for strong prescriptions",
                thicknessSavings: "~50% thinner than standard"
            )
        } else {
            return LensRecommendation(
                recommendedIndex: .highIndex,
                reason: "High-index lenses are essential for very strong prescriptions",
                thicknessSavings: "Up to 50% thinner - significant comfort improvement"
            )
        }
    }
}

// MARK: - Recommendation Card

struct RecommendationCard: View {
    let recommendation: LensRecommendation
    let prescriptionStrength: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                Text("Our Recommendation")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(recommendation.recommendedIndex.rawValue)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(recommendation.recommendedIndex.color)
                    
                    Spacer()
                    
                    if prescriptionStrength > 0 {
                        Text("±\(String(format: "%.2f", prescriptionStrength)) power")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(6)
                    }
                }
                
                Text(recommendation.reason)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: "ruler.fill")
                        .foregroundColor(recommendation.recommendedIndex.color)
                    Text(recommendation.thicknessSavings)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Material Comparison View

struct MaterialComparisonView: View {
    @Binding var selectedIndex: LensIndex
    let prescriptionStrength: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compare Materials")
                .font(.headline)
                .padding(.horizontal, 4)
            
            HStack(spacing: 12) {
                ForEach(LensIndex.allCases, id: \.self) { index in
                    VStack(spacing: 8) {
                        Image(systemName: index.icon)
                            .font(.title2)
                            .foregroundColor(selectedIndex == index ? .white : index.color)
                            .frame(height: 30)
                        
                        Text(index.rawValue)
                            .font(.caption)
                            .fontWeight(selectedIndex == index ? .semibold : .regular)
                            .multilineTextAlignment(.center)
                            .foregroundColor(selectedIndex == index ? .white : .primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        selectedIndex == index ?
                            index.color : Color(UIColor.secondarySystemGroupedBackground)
                    )
                    .cornerRadius(12)
                    .shadow(color: selectedIndex == index ? index.color.opacity(0.3) : .clear, radius: 8)
                }
            }
        }
    }
}

// MARK: - Thickness Visualization View

struct ThicknessVisualizationView: View {
    let prescriptionStrength: Double
    let selectedIndex: LensIndex
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Lens Thickness Comparison")
                .font(.headline)
                .padding(.horizontal, 4)
            
            VStack(spacing: 16) {
                ForEach(LensIndex.allCases, id: \.self) { index in
                    LensThicknessRow(
                        lensIndex: index,
                        prescriptionStrength: prescriptionStrength,
                        isSelected: selectedIndex == index
                    )
                }
            }
            .padding()
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
}

struct LensThicknessRow: View {
    let lensIndex: LensIndex
    let prescriptionStrength: Double
    let isSelected: Bool
    
    private var thickness: Double {
        lensIndex.thicknessMultiplier(for: prescriptionStrength)
    }
    
    private var maxThickness: Double {
        LensIndex.standard.thicknessMultiplier(for: prescriptionStrength)
    }
    
    private var normalizedWidth: CGFloat {
        if maxThickness == 0 { return 0.3 }
        return CGFloat(thickness / maxThickness)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(lensIndex.rawValue)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .regular)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(lensIndex.color)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.secondary.opacity(0.1))
                        .frame(height: 40)
                    
                    // Lens cross-section visualization
                    LensProfileShape(
                        prescriptionStrength: prescriptionStrength,
                        isNegative: prescriptionStrength < 0
                    )
                    .fill(
                        LinearGradient(
                            colors: [lensIndex.color.opacity(0.6), lensIndex.color],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(width: geometry.size.width * normalizedWidth)
                    
                    // Thickness label
                    Text("\(String(format: "%.1f", thickness * 10))mm")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(lensIndex.color)
                        .cornerRadius(6)
                        .offset(x: max(8, geometry.size.width * normalizedWidth - 50))
                }
            }
            .frame(height: 40)
        }
    }
}

// MARK: - Lens Profile Shape

struct LensProfileShape: Shape {
    let prescriptionStrength: Double
    let isNegative: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let curvature = min(abs(prescriptionStrength) * 0.1, 0.5)
        
        if isNegative {
            // Concave lens (thinner in center, thicker at edges)
            path.move(to: CGPoint(x: 0, y: rect.midY - rect.height * 0.3))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY - rect.height * 0.3),
                control1: CGPoint(x: rect.midX * 0.5, y: rect.midY + rect.height * curvature),
                control2: CGPoint(x: rect.midX * 1.5, y: rect.midY + rect.height * curvature)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + rect.height * 0.3))
            path.addCurve(
                to: CGPoint(x: 0, y: rect.midY + rect.height * 0.3),
                control1: CGPoint(x: rect.midX * 1.5, y: rect.midY - rect.height * curvature * 0.5),
                control2: CGPoint(x: rect.midX * 0.5, y: rect.midY - rect.height * curvature * 0.5)
            )
        } else {
            // Convex lens (thicker in center, thinner at edges)
            path.move(to: CGPoint(x: 0, y: rect.midY - rect.height * 0.2))
            path.addCurve(
                to: CGPoint(x: rect.maxX, y: rect.midY - rect.height * 0.2),
                control1: CGPoint(x: rect.midX * 0.5, y: rect.midY - rect.height * curvature),
                control2: CGPoint(x: rect.midX * 1.5, y: rect.midY - rect.height * curvature)
            )
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY + rect.height * 0.2))
            path.addCurve(
                to: CGPoint(x: 0, y: rect.midY + rect.height * 0.2),
                control1: CGPoint(x: rect.midX * 1.5, y: rect.midY + rect.height * curvature),
                control2: CGPoint(x: rect.midX * 0.5, y: rect.midY + rect.height * curvature)
            )
        }
        path.closeSubpath()
        
        return path
    }
}

// MARK: - Material Detail Card

struct MaterialDetailCard: View {
    let lensIndex: LensIndex
    let isSelected: Bool
    let prescriptionStrength: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: lensIndex.icon)
                    .font(.title2)
                    .foregroundColor(lensIndex.color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(lensIndex.rawValue)
                        .font(.headline)
                    
                    Text("Refractive Index: \(String(format: "%.2f", lensIndex.indexValue))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundColor(lensIndex.color)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(lensIndex.benefits, id: \.self) { benefit in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.caption)
                            .foregroundColor(lensIndex.color)
                        
                        Text(benefit)
                            .font(.subheadline)
                    }
                }
            }
        }
        .padding()
        .background(
            isSelected ?
                lensIndex.color.opacity(0.1) :
                Color(UIColor.secondarySystemGroupedBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? lensIndex.color : Color.clear, lineWidth: 2)
        )
        .cornerRadius(16)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LensSelectionView(prescription: .constant(Prescription(
            od: EyeData(sphere: "-6.00", cylinder: "-1.50", axis: "90"),
            os: EyeData(sphere: "-5.75", cylinder: "-1.25", axis: "85"),
            pd: "63.0"
        )))
    }
}
