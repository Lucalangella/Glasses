import SwiftUI

struct LensCoatingsView: View {
    @State private var selectedCoatings: Set<LensCoating> = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Lens Coatings & Treatments")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Enhance your lenses with protective coatings")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                
                // Essential Coatings
                VStack(alignment: .leading, spacing: 12) {
                    Label("Essential Coatings", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Text("Highly recommended for all prescriptions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(LensCoating.essentialCoatings, id: \.self) { coating in
                        CoatingCard(
                            coating: coating,
                            isSelected: selectedCoatings.contains(coating),
                            isEssential: true
                        ) {
                            toggleCoating(coating)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Optional Enhancements
                VStack(alignment: .leading, spacing: 12) {
                    Label("Optional Enhancements", systemImage: "wand.and.stars")
                        .font(.headline)
                        .foregroundColor(.purple)
                    
                    Text("Based on your lifestyle and needs")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                VStack(spacing: 12) {
                    ForEach(LensCoating.optionalCoatings, id: \.self) { coating in
                        CoatingCard(
                            coating: coating,
                            isSelected: selectedCoatings.contains(coating),
                            isEssential: false
                        ) {
                            toggleCoating(coating)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Summary Card
                if !selectedCoatings.isEmpty {
                    SelectionSummaryCard(selectedCoatings: selectedCoatings)
                        .padding(.horizontal)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("Lens Coatings")
        .navigationBarTitleDisplayMode(.inline)
        .animation(.spring(response: 0.3), value: selectedCoatings)
    }
    
    private func toggleCoating(_ coating: LensCoating) {
        if selectedCoatings.contains(coating) {
            selectedCoatings.remove(coating)
        } else {
            selectedCoatings.insert(coating)
        }
    }
}

// MARK: - Lens Coating Model

enum LensCoating: String, CaseIterable, Hashable {
    case antiReflective = "Anti-Reflective (AR)"
    case scratchResistant = "Scratch Resistant"
    case uvProtection = "UV Protection"
    case blueLight = "Blue Light Filter"
    case photochromic = "Photochromic (Transitions)"
    case polarized = "Polarized"
    case antiSmudge = "Anti-Smudge/Hydrophobic"
    
    static var essentialCoatings: [LensCoating] {
        [.antiReflective, .scratchResistant, .uvProtection]
    }
    
    static var optionalCoatings: [LensCoating] {
        [.blueLight, .photochromic, .polarized, .antiSmudge]
    }
    
    var description: String {
        switch self {
        case .antiReflective:
            return "Reduces glare and reflections, especially important for driving at night and using digital screens. Makes lenses nearly invisible."
        case .scratchResistant:
            return "Hardens the lens surface to protect against everyday scratches and extends the life of your glasses."
        case .uvProtection:
            return "Blocks 100% of harmful UVA and UVB rays, protecting your eyes from sun damage. Often included in polycarbonate lenses."
        case .blueLight:
            return "Filters blue light from digital screens and LED lighting, which may help reduce eye strain during extended screen time."
        case .photochromic:
            return "Lenses automatically darken in sunlight and clear up indoors. Convenient alternative to switching between glasses and sunglasses."
        case .polarized:
            return "Eliminates glare from reflective surfaces like water, snow, and roads. Best for outdoor activities and driving."
        case .antiSmudge:
            return "Repels water, oil, and fingerprints, making lenses easier to clean and keeping them clearer throughout the day."
        }
    }
    
    var icon: String {
        switch self {
        case .antiReflective: return "eye.fill"
        case .scratchResistant: return "shield.checkered"
        case .uvProtection: return "sun.max.fill"
        case .blueLight: return "laptopcomputer"
        case .photochromic: return "sun.and.horizon.fill"
        case .polarized: return "water.waves"
        case .antiSmudge: return "drop.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .antiReflective: return .blue
        case .scratchResistant: return .green
        case .uvProtection: return .orange
        case .blueLight: return .indigo
        case .photochromic: return .teal
        case .polarized: return .cyan
        case .antiSmudge: return .mint
        }
    }
    
    var benefits: [String] {
        switch self {
        case .antiReflective:
            return ["Clearer vision", "Reduced eye strain", "Better night driving", "Improved appearance"]
        case .scratchResistant:
            return ["Longer lens life", "Maintains clarity", "Protects investment"]
        case .uvProtection:
            return ["Prevents cataracts", "Reduces eye damage", "Year-round protection"]
        case .blueLight:
            return ["Reduced digital eye strain", "Better sleep quality", "Less headaches"]
        case .photochromic:
            return ["Convenience", "UV protection", "Adapts to lighting"]
        case .polarized:
            return ["Eliminates glare", "Enhanced contrast", "Better outdoor vision"]
        case .antiSmudge:
            return ["Easy to clean", "Stays clear longer", "Repels water"]
        }
    }
    
    var recommendedFor: [String] {
        switch self {
        case .antiReflective:
            return ["Everyone", "Night driving", "Computer work"]
        case .scratchResistant:
            return ["Everyone", "Active lifestyles", "Children"]
        case .uvProtection:
            return ["Everyone", "Outdoor activities", "Long-term eye health"]
        case .blueLight:
            return ["Office workers", "Students", "Gamers", "Heavy screen users"]
        case .photochromic:
            return ["People who go in/out frequently", "Don't want separate sunglasses"]
        case .polarized:
            return ["Drivers", "Water sports", "Snow sports", "Fishermen"]
        case .antiSmudge:
            return ["Everyone", "Humid climates", "People who handle glasses often"]
        }
    }
}

// MARK: - Coating Card

struct CoatingCard: View {
    let coating: LensCoating
    let isSelected: Bool
    let isEssential: Bool
    let action: () -> Void
    
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main Card Content
            Button(action: action) {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(coating.color.opacity(isSelected ? 1.0 : 0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: coating.icon)
                            .foregroundColor(isSelected ? .white : coating.color)
                    }
                    
                    // Title & Description
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(coating.rawValue)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            if isEssential {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                            }
                        }
                        
                        Text(coating.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(isExpanded ? nil : 2)
                    }
                    
                    Spacer()
                    
                    // Selection indicator
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title3)
                        .foregroundColor(isSelected ? coating.color : .secondary.opacity(0.3))
                }
                .padding()
            }
            .buttonStyle(.plain)
            
            // Expanded Details
            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    Divider()
                        .padding(.horizontal)
                    
                    // Benefits
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Benefits")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(coating.color)
                        
                        ForEach(coating.benefits, id: \.self) { benefit in
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                    .font(.caption2)
                                    .foregroundColor(coating.color)
                                
                                Text(benefit)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Recommended For
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Recommended For")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(coating.color)
                        
                        FlowLayout(spacing: 8) {
                            ForEach(coating.recommendedFor, id: \.self) { recommendation in
                                Text(recommendation)
                                    .font(.caption2)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(coating.color.opacity(0.15))
                                    .foregroundColor(coating.color)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 8)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            // Expand/Collapse Button
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Spacer()
                    Text(isExpanded ? "Show Less" : "Learn More")
                        .font(.caption)
                        .foregroundColor(coating.color)
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(coating.color)
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(coating.color.opacity(0.05))
            }
            .buttonStyle(.plain)
        }
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? coating.color : Color.clear, lineWidth: 2)
        )
        .shadow(color: isSelected ? coating.color.opacity(0.2) : .clear, radius: 8)
    }
}

// MARK: - Selection Summary Card

struct SelectionSummaryCard: View {
    let selectedCoatings: Set<LensCoating>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "cart.fill")
                    .foregroundColor(.accentColor)
                
                Text("Your Selection")
                    .font(.headline)
                
                Spacer()
                
                Text("\(selectedCoatings.count) coating\(selectedCoatings.count == 1 ? "" : "s")")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.accentColor.opacity(0.2))
                    .foregroundColor(.accentColor)
                    .cornerRadius(8)
            }
            
            Divider()
            
            ForEach(Array(selectedCoatings), id: \.self) { coating in
                HStack(spacing: 8) {
                    Image(systemName: coating.icon)
                        .foregroundColor(coating.color)
                        .frame(width: 20)
                    
                    Text(coating.rawValue)
                        .font(.subheadline)
                    
                    Spacer()
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
}

// MARK: - Flow Layout (for tags)

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowLayoutResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowLayoutResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowLayoutResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LensCoatingsView()
    }
}
