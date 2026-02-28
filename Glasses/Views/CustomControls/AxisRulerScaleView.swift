import SwiftUI

struct AxisRulerScaleView: View {
    @Binding var value: Double
    
    // Ruler configuration
    @State private var dragOffset: CGFloat = 0
    @State private var lastHapticValue: Int = 0
    @State private var baseValue: Double = 0
    @State private var isDragging: Bool = false
    
    private let range: ClosedRange<Double> = 0.0...180.0
    private let pointsPerDegree: CGFloat = 8
    
    // Calculates the snapped value for the UI (Header + Ticks)
    var currentVisualValue: Double {
        if !isDragging { return value }
        
        let offsetDegrees = Double(-dragOffset / pointsPerDegree)
        let rawValue = baseValue + offsetDegrees
        
        // Snap to whole degrees for Axis
        return round(rawValue).clamped(to: range)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            
            // MARK: - 1. Large Display Header
            VStack(spacing: 4) {
                Text("\(Int(currentVisualValue))°")
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
                    ForEach(stride(from: 0, through: 180, by: 1).map { $0 }, id: \.self) { tickInt in
                        let tick = Double(tickInt)
                        let distance = tick - currentVisualValue
                        let xOffset = center + CGFloat(distance) * pointsPerDegree
                        
                        if xOffset > -30 && xOffset < width + 30 {
                            tickView(for: tickInt)
                                .position(x: xOffset, y: 30)
                        }
                    }
                    
                    // Center Fixed Indicator
                    VStack(spacing: 16) {
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
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { drag in
                            if !isDragging {
                                isDragging = true
                                baseValue = value
                            }
                            
                            dragOffset = drag.translation.width
                            
                            let snapped = Int(currentVisualValue)
                            
                            if snapped != lastHapticValue {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                lastHapticValue = snapped
                                
                                // Live update the binding so external views (like a protractor) move
                                if value != Double(snapped) {
                                    value = Double(snapped)
                                }
                            }
                        }
                        .onEnded { drag in
                            // Add momentum calculation
                            let predictedOffset = Double(-drag.predictedEndTranslation.width / pointsPerDegree)
                            let predictedRawValue = baseValue + predictedOffset
                            let finalValue = round(predictedRawValue).clamped(to: range)
                            
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                            
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                value = finalValue
                                dragOffset = 0
                                isDragging = false
                            }
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
            .padding(.bottom, 32)
        }
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(24)
        .onAppear {
            lastHapticValue = Int(value)
        }
    }
    
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
                Text("0").font(.system(size: 10)).opacity(0)
            }
        }
    }
}


