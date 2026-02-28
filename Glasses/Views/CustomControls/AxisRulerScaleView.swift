import SwiftUI

struct AxisRulerScaleView: View {
    @Binding var value: Double
    
    // Ruler configuration
    @State private var dragOffset: CGFloat = 0
    @State private var lastHapticValue: Int = 0 // Tracks haptics during drag
    @State private var baseValue: Double? = nil // Captures the start value for smooth dragging
    
    private let range: ClosedRange<Double> = 0.0...180.0
    private let pointsPerDegree: CGFloat = 8 // Distance between each 1-degree tick
    
    // Calculates the live value while the user's finger is dragging
    var currentVisualValue: Double {
        let base = baseValue ?? value
        let offsetDegrees = Double(-dragOffset / pointsPerDegree)
        return base + offsetDegrees
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - 1. Large Display Header
            VStack(spacing: 4) {
                // Ensure we never display a negative 0 or out of bounds number during the bounce
                Text("\(Int(max(0, min(180, round(currentVisualValue)))))°")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .monospacedDigit()
                
                Text("Cylinder Axis")
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.secondary)
            }
            .padding(.top, 24)
            .padding(.bottom, 24)
            
            // MARK: - 2. Scrolling Ruler
            GeometryReader { geo in
                let width = geo.size.width
                let center = width / 2
                
                ZStack {
                    // Ticks
                    ForEach(0...180, id: \.self) { tickInt in
                        let tick = Double(tickInt)
                        let distance = tick - currentVisualValue
                        let xOffset = center + CGFloat(distance) * pointsPerDegree
                        
                        // Optimization: Only render ticks that are currently visible
                        if xOffset > -30 && xOffset < width + 30 {
                            tickView(for: tickInt)
                                .position(x: xOffset, y: 30) // Center vertically in the 60pt height
                        }
                    }
                    
                    // Center Fixed Indicator (The yellow line and gray dot)
                    VStack(spacing: 4) {
                        Rectangle()
                            .fill(Color.yellow)
                            .frame(width: 2, height: 32)
                            .cornerRadius(1)
                        
                        Circle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(width: 4, height: 4)
                    }
                    .position(x: center, y: 30)
                }
                .contentShape(Rectangle()) // Make the area draggable
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            // Capture the base value when the drag starts
                            if baseValue == nil {
                                baseValue = value
                            }
                            
                            // 1. Update the visual offset
                            dragOffset = drag.translation.width
                            
                            // 2. Play a light "tick" as the user drags over degrees
                            let rawValue = currentVisualValue
                            let snapped = Int(round(rawValue))
                            
                            if snapped != lastHapticValue && snapped >= Int(range.lowerBound) && snapped <= Int(range.upperBound) {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                lastHapticValue = snapped
                            }
                            
                            // 3. LIVE UPDATE: Update the external value so the protractor moves in real-time
                            let clamped = min(max(Double(snapped), range.lowerBound), range.upperBound)
                            if value != clamped {
                                value = clamped
                            }
                        }
                        .onEnded { drag in
                            // Calculate velocity and add momentum
                            let predictedOffset = Double(-drag.predictedEndTranslation.width / pointsPerDegree)
                            let base = baseValue ?? value
                            let predictedRawValue = base + predictedOffset
                            
                            // Snap the predicted landing spot to the nearest whole degree
                            let snapped = round(predictedRawValue)
                            let clamped = min(max(snapped, range.lowerBound), range.upperBound)
                            
                            // Fire a slightly heavier haptic to signify it "locked" in
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            
                            // Calculate the target drag offset that corresponds to the clamped value
                            let targetOffset = CGFloat(-(clamped - base) * pointsPerDegree)
                            
                            // Smoothly animate the wheel spinning to its final resting place
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                dragOffset = targetOffset
                                value = clamped
                            }
                            
                            // Clean up internal state after the animation completes
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                                baseValue = nil
                                dragOffset = 0
                            }
                        }
                )
            }
            .frame(height: 60)
            // Fade out the edges of the ruler
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
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.primary.opacity(0.05), lineWidth: 1)
        )
        // Reset haptic state when view appears
        .onAppear {
            lastHapticValue = Int(value)
        }
    }
    
    // MARK: - Helpers
    
    @ViewBuilder
    private func tickView(for tick: Int) -> some View {
        let isMajor = tick % 10 == 0
        let isMedium = tick % 5 == 0 && !isMajor
        
        VStack(spacing: 4) {
            Rectangle()
                .fill(isMajor ? Color.primary : Color.secondary.opacity(0.4))
                .frame(width: 1.5, height: isMajor ? 24 : (isMedium ? 16 : 10))
                .cornerRadius(1)
            
            if isMajor {
                Text("\(tick)")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.secondary)
            } else {
                Text("0")
                    .font(.system(size: 10))
                    .opacity(0) // Invisible spacer
            }
        }
    }
}
