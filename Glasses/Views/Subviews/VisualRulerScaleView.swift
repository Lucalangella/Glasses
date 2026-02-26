import SwiftUI

struct VisualRulerScaleView: View {
    @Binding var value: Double
    
    // Ruler configuration
    @State private var dragOffset: CGFloat = 0
    private let range: ClosedRange<Double> = -20.0...20.0
    private let tickSpacing: CGFloat = 20
    private let pointsPerDiopter: CGFloat = 80 // 20 spacing * 4 ticks per diopter (0.25 steps)
    
    // Calculates the live value while the user's finger is dragging
    var currentVisualValue: Double {
        let offsetDiopters = Double(-dragOffset / pointsPerDiopter)
        return value + offsetDiopters
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - 1. Large Display Header
            VStack(spacing: 6) {
                Text(formatValue(currentVisualValue))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .monospacedDigit()
                
                Text(conditionText(for: currentVisualValue))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(conditionColor(for: currentVisualValue))
            }
            .padding(.top, 24)
            .padding(.bottom, 32)
            
            // MARK: - 2. Scrolling Ruler
            GeometryReader { geo in
                let width = geo.size.width
                let center = width / 2
                
                ZStack {
                    // Ticks
                    ForEach(stride(from: range.lowerBound, through: range.upperBound, by: 0.25).map { $0 }, id: \.self) { tick in
                        let distance = tick - currentVisualValue
                        let xOffset = center + CGFloat(distance) * pointsPerDiopter
                        
                        // Optimization: Only render ticks that are currently visible on screen
                        if xOffset > -20 && xOffset < width + 20 {
                            tickView(for: tick)
                                .position(x: xOffset, y: 30) // Vertical center of the 60pt area
                        }
                    }
                    
                    // Center Fixed Indicator (The blue selector line)
                    VStack {
                        Rectangle()
                            .fill(Color.accentColor)
                            .frame(width: 3, height: 40)
                            .cornerRadius(1.5)
                        Spacer()
                    }
                    .frame(height: 60)
                    .position(x: center, y: 30)
                }
                .contentShape(Rectangle()) // Make the entire transparent area draggable
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            dragOffset = drag.translation.width
                        }
                        .onEnded { drag in
                            let offsetDiopters = Double(-drag.translation.width / pointsPerDiopter)
                            let rawValue = value + offsetDiopters
                            
                            // Snap to nearest 0.25
                            let snapped = round(rawValue * 4) / 4
                            let clamped = min(max(snapped, range.lowerBound), range.upperBound)
                            
                            // Haptic click when snapping into place
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                                value = clamped
                                dragOffset = 0
                            }
                        }
                )
            }
            .frame(height: 60)
            // Fades out the edges of the ruler for a premium 3D cylinder effect
            .mask(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black, location: 0.2),
                        .init(color: .black, location: 0.8),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .leading, endPoint: .trailing
                )
            )
            .padding(.bottom, 24)
            
            // MARK: - 3. Visual Guide Arrows
            HStack {
                Image(systemName: "arrow.left")
                Text("Myopia")
                Spacer()
                Text("Hyperopia")
                Image(systemName: "arrow.right")
            }
            .font(.caption2.weight(.semibold))
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
            
        }
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func tickView(for tickValue: Double) -> some View {
        let isMajor = tickValue.truncatingRemainder(dividingBy: 1.0) == 0
        let isHalf = tickValue.truncatingRemainder(dividingBy: 0.5) == 0 && !isMajor
        
        VStack(spacing: 6) {
            Rectangle()
                .fill(isMajor ? Color.primary : Color.secondary.opacity(0.4))
                .frame(width: isMajor ? 2 : 1.5, height: isMajor ? 24 : (isHalf ? 16 : 10))
                .cornerRadius(1)
            
            if isMajor {
                Text(String(format: "%.0f", tickValue))
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.secondary)
            } else {
                // Invisible spacer to keep all ticks vertically aligned at the top
                Text("0")
                    .font(.system(size: 11))
                    .opacity(0)
            }
        }
    }
    
    private func formatValue(_ val: Double) -> String {
        let snapped = round(val * 4) / 4 // Ensures the live drag text shows rounded steps
        if abs(snapped) < 0.05 { return "0.00" }
        return String(format: "%+.2f", snapped)
    }
    
    private func conditionText(for val: Double) -> String {
        if val <= -0.25 { return "Increasing Myopia" }
        if val >= 0.25 { return "Increasing Hyperopia" }
        return "Clear Vision"
    }
    
    private func conditionColor(for val: Double) -> Color {
        if val <= -0.25 { return .blue.opacity(0.8) }
        if val >= 0.25 { return .orange.opacity(0.8) }
        return .green.opacity(0.8)
    }
}

#Preview {
    VisualRulerScaleView(value: .constant(-2.75))
        .padding()
}
