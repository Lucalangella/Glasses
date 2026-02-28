
import SwiftUI

struct VisualRulerScaleView: View {
    @Binding var value: Double
        
        // Ruler configuration
        @State private var dragOffset: CGFloat = 0
        @State private var lastHapticValue: Double = 0
        @State private var baseValue: Double = 0 // Initialize with 0
        @State private var isDragging: Bool = false // Tracks if we are currently mid-drag
        
        private let range: ClosedRange<Double> = -20.0...20.0
        private let pointsPerDiopter: CGFloat = 80
    private let step: Double = 0.25
        
        // This is the source of truth for the Header and the Ticks
        var currentVisualValue: Double {
            // If not dragging, show the actual binding value
            if !isDragging { return value }
            
            // If dragging, calculate the offset from where the drag started
            let offsetDiopters = Double(-dragOffset / pointsPerDiopter)
            let rawValue = baseValue + offsetDiopters
            
            // Snap to 0.25 and clamp to range
            return (round(rawValue * 4) / 4).clamped(to: range)
        }

    // 2. Simplify the formatter so it just displays the snapped value
    private func formatValue(_ val: Double) -> String {
        // No more internal rounding here; currentVisualValue is already snapped
        if abs(val) < 0.01 { return "0.00" }
        return String(format: "%+.2f", val)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 1. Header
            VStack(spacing: 6) {
                Text(formatValue(currentVisualValue))
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                
                Text(conditionText(for: currentVisualValue))
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(conditionColor(for: currentVisualValue))
            }
            .padding(.vertical, 24)
            
            // MARK: - 2. Scrolling Ruler
            GeometryReader { geo in
                let width = geo.size.width
                let center = width / 2
                
                ZStack {
                    // Ticks Layer
                    // Optimization: stride is fine, but moved map inside or used id: \.self
                    ForEach(stride(from: range.lowerBound, through: range.upperBound, by: step).map { $0 }, id: \.self) { tick in
                        let distance = tick - currentVisualValue
                        let xOffset = center + CGFloat(distance) * pointsPerDiopter
                        
                        if xOffset > -20 && xOffset < width + 20 {
                            tickView(for: tick)
                                .position(x: xOffset, y: 30)
                        }
                    }
                    
                    // Center Indicator
                    Rectangle()
                        .fill(Color.accentColor)
                        .frame(width: 3, height: 40)
                        .cornerRadius(1.5)
                        .position(x: center, y: 30)
                }
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            if !isDragging {
                                isDragging = true
                                baseValue = value // Capture the starting point immediately
                            }
                            
                            dragOffset = drag.translation.width
                            
                            let snapped = currentVisualValue
                            
                            // Only trigger haptics when the visible number actually changes
                            if snapped != lastHapticValue {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                lastHapticValue = snapped
                                
                                // Optional: Update the binding live so other UI
                                // elements react to the "snapped" changes
                                if value != snapped {
                                    value = snapped
                                }
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                dragOffset = 0
                                isDragging = false
                            }
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                )
            }
            .frame(height: 60)
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
            
            // MARK: - 3. Labels
            HStack {
                Label("Myopia", systemImage: "arrow.left")
                Spacer()
                Label("Hyperopia", systemImage: "arrow.right")
            }
            .labelStyle(.titleAndIcon)
            .font(.caption2.weight(.semibold))
            .foregroundColor(.secondary.opacity(0.6))
            .padding(.horizontal, 24)
            .padding(.bottom, 20)
        }
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(24)
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

// Helper to keep code clean
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}
