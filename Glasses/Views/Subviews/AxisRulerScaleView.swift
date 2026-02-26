import SwiftUI

struct AxisRulerScaleView: View {
    @Binding var value: Double
    
    // Drag state for real-time calculation
    @State private var initialDragValue: Double = 0
    @State private var isDragging: Bool = false
    @State private var lastHapticValue: Int = 0
    
    private let range: ClosedRange<Double> = 0.0...180.0
    private let pointsPerDegree: CGFloat = 8 // Distance between each 1-degree tick
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - 1. Large Display Header
            VStack(spacing: 4) {
                Text("\(Int(round(value)))°")
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
                        let distance = tick - value
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
                            // 1. Capture the starting value when the drag begins
                            if !isDragging {
                                isDragging = true
                                initialDragValue = value
                                lastHapticValue = Int(value)
                            }
                            
                            // 2. Calculate the new position based on how far the finger moved
                            let offsetDegrees = Double(-drag.translation.width / pointsPerDegree)
                            let rawValue = initialDragValue + offsetDegrees
                            
                            // 3. Snap to 1 degree increments and clamp to bounds
                            let snapped = round(rawValue)
                            let clamped = min(max(snapped, range.lowerBound), range.upperBound)
                            
                            // 4. Play a light haptic tick ONLY when crossing over a new degree
                            if Int(clamped) != lastHapticValue {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                lastHapticValue = Int(clamped)
                            }
                            
                            // 5. Update the binding in real-time! This instantly spins the protractor above.
                            value = clamped
                        }
                        .onEnded { _ in
                            isDragging = false
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
