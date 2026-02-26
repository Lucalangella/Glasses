import SwiftUI

struct ProtractorView: View {
    @Binding var axisText: String
    var isOS: Bool
    
    // Track if the user's finger is actively moving the needle
    @State private var isDragging: Bool = false
    @State private var lastHapticAngle: Int = -1
    
    var axisValue: Double {
        Double(axisText) ?? 0
    }
    
    var normalizedValue: Double {
        if axisValue == 0 || axisValue == 180 { return axisValue }
        var val = axisValue.truncatingRemainder(dividingBy: 180)
        if val < 0 { val += 180 }
        return val
    }
    
    var visualAngle: Double {
        if isOS {
            return normalizedValue
        } else {
            return 180 - normalizedValue
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let radius = min(width / 2, height) * 0.75
            let center = CGPoint(x: width / 2, y: height - 20)

            ZStack {
                ProtractorBackgroundShape(radius: radius, center: center)
                    .stroke(Color.primary, lineWidth: 1.5)

                ForEach(0...18, id: \.self) { i in
                    let theta = Double(i * 10)
                    if Int(theta) % 30 == 0 || theta == 0 || theta == 180 || theta == 100 || theta == 80 {
                        let valueToShow = isOS ? Int(theta) : 180 - Int(theta)
                        labelView(valueToShow: valueToShow, theta: theta, radius: radius, center: center)
                    }
                }

                ArrowPathShape(angle: visualAngle, center: center, radius: radius)
                    .stroke(Color.primary, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                    // Remove animation while dragging so the needle sticks perfectly to the finger
                    .animation(isDragging ? .none : .spring(response: 0.4, dampingFraction: 0.75), value: visualAngle)
                
                Circle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 8)
                    .position(x: center.x, y: center.y)
            }
            .contentShape(Rectangle()) // Makes the whole ZStack tappable/draggable
            .gesture(
                DragGesture(minimumDistance: 0) // 0 allows both taps and drags
                    .onChanged { value in
                        isDragging = true
                        updateAxis(from: value.location, center: center)
                    }
                    .onEnded { _ in
                        isDragging = false
                        // Give a satisfying thunk when they let go of the needle
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    }
            )
        }
    }

    private func updateAxis(from location: CGPoint, center: CGPoint) {
        let dx = location.x - center.x
        let dy = center.y - location.y // Invert Y because SwiftUI coordinates go down

        var angle = atan2(dy, dx) * 180 / .pi

        // Normalize to positive degrees
        if angle < 0 {
            angle += 360
        }

        // Constrain to the upper semicircle (0 to 180)
        if angle > 180 {
            // If they drag below the line, snap to the closest edge (0 or 180)
            angle = (angle > 270) ? 0 : 180
        }

        let newVisualAngle = Int(round(angle))
        
        // --- HAPTIC LOGIC ---
        // Fire haptics as they drag across the physical degrees
        if newVisualAngle != lastHapticAngle {
            if newVisualAngle % 10 == 0 {
                // A slightly heavier click on major 10-degree marks
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } else {
                // A light tick on every single degree
                UIImpactFeedbackGenerator(style: .light).impactOccurred()
            }
            lastHapticAngle = newVisualAngle
        }
        
        // Reverse the visual angle math to get the actual Rx Axis
        let newAxis = isOS ? Double(newVisualAngle) : 180.0 - Double(newVisualAngle)
        
        // Update the bound text field directly
        axisText = String(format: "%.0f", newAxis)
    }

    func labelView(valueToShow: Int, theta: Double, radius: CGFloat, center: CGPoint) -> some View {
        let angleRad = theta * .pi / 180
        let labelRadius = radius + 25
        
        let x = center.x + labelRadius * CGFloat(cos(angleRad))
        let y = center.y - labelRadius * CGFloat(sin(angleRad))

        return Text("\(valueToShow)")
            .font(.caption)
            .foregroundColor(.secondary)
            .position(x: x, y: y)
    }
}

struct ProtractorBackgroundShape: Shape {
    let radius: CGFloat
    let center: CGPoint

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        path.addArc(center: center, radius: radius * 0.5, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: false)
        
        path.move(to: CGPoint(x: center.x - radius, y: center.y))
        path.addLine(to: CGPoint(x: center.x + radius, y: center.y))

        for i in 0...180 {
            if i % 10 == 0 {
                let angleRad = Double(i) * .pi / 180
                let innerRad = (i % 30 == 0 || i == 0 || i == 180 || i == 80 || i == 100) ? radius * 0.82 : radius * 0.90
                
                let startX = center.x + radius * CGFloat(cos(angleRad))
                let startY = center.y - radius * CGFloat(sin(angleRad))
                let endX = center.x + innerRad * CGFloat(cos(angleRad))
                let endY = center.y - innerRad * CGFloat(sin(angleRad))

                path.move(to: CGPoint(x: startX, y: startY))
                path.addLine(to: CGPoint(x: endX, y: endY))
            }
        }
        return path
    }
}

struct ArrowPathShape: Shape {
    var angle: Double
    var center: CGPoint
    var radius: CGFloat

    var animatableData: Double {
        get { angle }
        set { angle = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var p = Path()
        let shaftLength = radius * 0.85
        let rad = angle * .pi / 180.0
        
        let endX = center.x + shaftLength * CGFloat(cos(rad))
        let endY = center.y - shaftLength * CGFloat(sin(rad))
        
        let tailLength = radius * 0.15
        let tailX = center.x - tailLength * CGFloat(cos(rad))
        let tailY = center.y + tailLength * CGFloat(sin(rad))
        
        p.move(to: CGPoint(x: tailX, y: tailY))
        p.addLine(to: CGPoint(x: endX, y: endY))
        
        let headLength: CGFloat = 16
        let headAngle = 25.0 * .pi / 180.0
        
        let leftWingRad = rad + headAngle + .pi
        let leftX = endX + headLength * CGFloat(cos(leftWingRad))
        let leftY = endY - headLength * CGFloat(sin(leftWingRad))
        
        let rightWingRad = rad - headAngle + .pi
        let rightX = endX + headLength * CGFloat(cos(rightWingRad))
        let rightY = endY - headLength * CGFloat(sin(rightWingRad))
        
        p.move(to: CGPoint(x: endX, y: endY))
        p.addLine(to: CGPoint(x: leftX, y: leftY))
        p.move(to: CGPoint(x: endX, y: endY))
        p.addLine(to: CGPoint(x: rightX, y: rightY))
        
        return p
    }
}
