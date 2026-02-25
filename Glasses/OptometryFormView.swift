//
//  OptometryFormView.swift
//  Glasses
//

import SwiftUI
import SceneKit
import ARKit
import RealityKit // Needed for the AR Face Tracking view

struct OptometryFormView: View {
    @State private var odSphere = ""
    @State private var odCyl = ""
    @State private var odAxis = ""

    @State private var osSphere = ""
    @State private var osCyl = ""
    @State private var osAxis = ""

    @State private var pdValue = ""

    // Computes axis dynamically
    private var odActiveAxis: Double {
        if let val = Double(odAxis) { return val }
        return 0
    }
    
    private var osActiveAxis: Double {
        if let val = Double(osAxis) { return val }
        return 0
    }
    
    // MARK: - Smart Lens Thickness Logic
    private var recommendedFrames: Set<String> {
        let odS = abs(Double(odSphere) ?? 0)
        let osS = abs(Double(osSphere) ?? 0)
        let odC = abs(Double(odCyl) ?? 0)
        let osC = abs(Double(osCyl) ?? 0)
        
        let maxPower = max(odS, osS) + max(odC, osC)
        
        if maxPower >= 4.0 {
            return ["round", "oval"]
        }
        return []
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    FramesGridView(recommendedFrames: recommendedFrames)
                        .padding(.top, 16)
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Tabo")
                            .font(.title3)
                            .padding(.trailing, 8)
                        
                        // Modified HStack to include PD in the middle
                        HStack(spacing: 16) {
                            VStack {
                                ProtractorView(axisValue: odActiveAxis, isOS: false)
                                    .frame(height: 160)
                                Text("OD")
                                    .font(.title)
                            }
                            
                            // NEW: Bridging PD Section
                            VStack(spacing: 6) {
                                Text("PD")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 2) {
                                    TextField("63", text: $pdValue)
                                        .keyboardType(.decimalPad)
                                        .multilineTextAlignment(.center)
                                        .frame(width: 44)
                                    
                                    Text("mm")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 10)
                                .background(Color(UIColor.secondarySystemGroupedBackground))
                                .cornerRadius(12)
                            }
                            // Pushes the PD box down slightly so it aligns well with the flat bottom of the semicircles
                            .padding(.top, 50)
                            
                            VStack {
                                ProtractorView(axisValue: osActiveAxis, isOS: true)
                                    .frame(height: 160)
                                Text("OS")
                                    .font(.title)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    PrescriptionTableView(
                        odSphere: $odSphere, odCyl: $odCyl, odAxis: $odAxis,
                        osSphere: $osSphere, osCyl: $osCyl, osAxis: $osAxis
                        // pdValue removed from here
                    )
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Clarity")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: String.self) { frameName in
                Glasses3DView(frameName: frameName)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }
}

// MARK: - 3D DESTINATION VIEW (Now with AR Try-On)
struct Glasses3DView: View {
    var frameName: String
    @State private var isShowingARView = false
    
    private var scene: SCNScene? {
        return SCNScene(named: "\(frameName).usdz")
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(frameName.capitalized.replacingOccurrences(of: "_", with: " "))
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)
            
            if scene != nil {
                SceneView(
                    scene: scene,
                    options: [.autoenablesDefaultLighting, .allowsCameraControl]
                )
                .frame(height: 400)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding()
                
                // AR Try-On Button
                Button(action: {
                    isShowingARView = true
                }) {
                    HStack {
                        Image(systemName: "face.dashed")
                            .font(.title2)
                        Text("Virtual Try-On")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(14)
                    .padding(.horizontal)
                }
                
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "arkit")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Add '\(frameName).usdz' to your project\nto view the 3D model.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding()
            }
            
            Spacer()
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("3D Preview")
        .navigationBarTitleDisplayMode(.inline)
        // Presents the full-screen AR experience
        .fullScreenCover(isPresented: $isShowingARView) {
            ARFaceTrackingContainer(frameName: frameName, isPresented: $isShowingARView)
                .ignoresSafeArea()
        }
    }
}


// MARK: - ARKit FACE TRACKING WRAPPER (WITH LIVE DEBUGGER)
struct ARFaceTrackingContainer: View {
    var frameName: String
    @Binding var isPresented: Bool
    
    // Debugger State Variables
    @State private var modelScale: Float = 1.0
    @State private var offsetX: Float = 0.0
    @State private var offsetY: Float = 0.0
    @State private var offsetZ: Float = 0.02 // Starts slightly forward so it doesn't clip into the nose
    
    var body: some View {
        ZStack {
            // The AR Camera View
            ARFaceTrackingView(
                frameName: frameName,
                modelScale: modelScale,
                offsetX: offsetX,
                offsetY: offsetY,
                offsetZ: offsetZ
            )
            .ignoresSafeArea()
            
            // Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .padding()
                            .background(Circle().fill(Color.black.opacity(0.4)))
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
            
            // MARK: - Live Debugger Panel
            VStack {
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Live Positioning Debugger")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    debugSlider(title: "Scale", value: $modelScale, range: 0.1...3.0)
                    debugSlider(title: "X (L/R)", value: $offsetX, range: -0.1...0.1)
                    debugSlider(title: "Y (Up/Dn)", value: $offsetY, range: -0.1...0.1)
                    debugSlider(title: "Z (In/Out)", value: $offsetZ, range: -0.1...0.2)
                    
                    Text("Copy these values when it looks right!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(20)
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }
    
    // Helper view for the debugger sliders
    private func debugSlider(title: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        HStack {
            Text("\(title):")
                .font(.caption.monospacedDigit())
                .frame(width: 75, alignment: .leading)
            
            Slider(value: value, in: range)
                .tint(.accentColor)
            
            Text(String(format: "%.3f", value.wrappedValue))
                .font(.caption.monospacedDigit())
                .frame(width: 50, alignment: .trailing)
        }
    }
}

// MARK: - THE AR VIEW
struct ARFaceTrackingView: UIViewRepresentable {
    var frameName: String
    
    // Incoming values from the SwiftUI sliders
    var modelScale: Float
    var offsetX: Float
    var offsetY: Float
    var offsetZ: Float
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        guard ARFaceTrackingConfiguration.isSupported else {
            print("Face tracking is not supported on this device.")
            return arView
        }
        
        let configuration = ARFaceTrackingConfiguration()
        arView.session.run(configuration)
        
        if let glassesEntity = try? Entity.load(named: "\(frameName).usdz") {
            // 1. Give the entity a specific name so we can find it later to update it
            glassesEntity.name = "virtualGlasses"
            
            let faceAnchor = AnchorEntity(.face)
            faceAnchor.addChild(glassesEntity)
            arView.scene.addAnchor(faceAnchor)
        }
        
        return arView
    }
    
    // This function runs automatically every time a slider is dragged!
    func updateUIView(_ uiView: ARView, context: Context) {
        // 2. Find the glasses model in the scene
        guard let glassesEntity = uiView.scene.findEntity(named: "virtualGlasses") else { return }
        
        // 3. Update its size and position instantly
        glassesEntity.scale = SIMD3<Float>(repeating: modelScale)
        glassesEntity.position = SIMD3<Float>(offsetX, offsetY, offsetZ)
    }
}

// MARK: - FRAMES GRID VIEW
struct FramesGridView: View {
    var recommendedFrames: Set<String>
    
    let frames = [
        "aviator", "browline", "cateye",
        "geometric", "oval", "oversized",
        "rectangle", "round", "square"
    ]
    
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Select Frame Style")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                if !recommendedFrames.isEmpty {
                    Text("Recommendations based on Rx")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(frames, id: \.self) { frameName in
                    let isRecommended = recommendedFrames.contains(frameName)
                    
                    NavigationLink(value: frameName) {
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Image(frameName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 40)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isRecommended ? Color.accentColor : Color.clear, lineWidth: 2)
                                    )
                                
                                if isRecommended {
                                    Image(systemName: "sparkles")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.accentColor)
                                        .clipShape(Circle())
                                        .offset(x: 6, y: -6)
                                }
                            }
                            
                            Text(frameName.capitalized.replacingOccurrences(of: "_", with: " "))
                                .font(.caption2)
                                .fontWeight(isRecommended ? .bold : .medium)
                                .foregroundColor(isRecommended ? .primary : .secondary)
                        }
                        .opacity(!recommendedFrames.isEmpty && !isRecommended ? 0.6 : 1.0)
                        .animation(.easeInOut, value: recommendedFrames)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - BULLETPROOF PROTRACTOR VIEW
struct ProtractorView: View {
    var axisValue: Double
    var isOS: Bool
    
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
                    .animation(.spring(response: 0.4, dampingFraction: 0.75), value: visualAngle)
                
                Circle()
                    .fill(Color.primary)
                    .frame(width: 8, height: 8)
                    .position(x: center.x, y: center.y)
            }
        }
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

// MARK: - Arcs and Ticks Background
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

// MARK: - The Pure Math Arrow
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

// MARK: - Native Apple Style Prescription Table
struct PrescriptionTableView: View {
    @Binding var odSphere: String
    @Binding var odCyl: String
    @Binding var odAxis: String
    
    @Binding var osSphere: String
    @Binding var osCyl: String
    @Binding var osAxis: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            eyeSection(title: "Right Eye (OD)", sph: $odSphere, cyl: $odCyl, axis: $odAxis)
            eyeSection(title: "Left Eye (OS)", sph: $osSphere, cyl: $osCyl, axis: $osAxis)
        }
        .padding(.horizontal)
    }
    
    private func eyeSection(title: String, sph: Binding<String>, cyl: Binding<String>, axis: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            HStack(spacing: 0) {
                inputColumn(title: "SPH", placeholder: "0.00", text: sph, hasSignToggle: true)
                verticalDivider()
                inputColumn(title: "CYL", placeholder: "0.00", text: cyl, hasSignToggle: true)
                verticalDivider()
                inputColumn(title: "AXIS", placeholder: "0", text: axis, isAxis: true)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
    
    private func inputColumn(title: String, placeholder: String, text: Binding<String>, isAxis: Bool = false, hasSignToggle: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                if hasSignToggle {
                    Button(action: {
                        toggleSign(for: text)
                    }) {
                        Text("±")
                            .font(.body.weight(.bold))
                            .foregroundColor(.accentColor)
                            .frame(minWidth: 20)
                    }
                    .buttonStyle(.plain)
                }
                
                TextField(placeholder, text: text)
                    .keyboardType(isAxis ? .numberPad : .decimalPad)
                    .font(.body)
                    .onChange(of: text.wrappedValue) { newValue in
                        if isAxis {
                            text.wrappedValue = newValue.filter { "0123456789".contains($0) }
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private func toggleSign(for text: Binding<String>) {
        var currentText = text.wrappedValue
        if currentText.hasPrefix("+") {
            currentText.removeFirst()
            text.wrappedValue = "-" + currentText
        } else if currentText.hasPrefix("-") {
            currentText.removeFirst()
            text.wrappedValue = "+" + currentText
        } else if !currentText.isEmpty {
            text.wrappedValue = "+" + currentText
        } else {
            text.wrappedValue = "+"
        }
    }
    
    private func verticalDivider() -> some View {
        Divider()
            .frame(height: 36)
            .padding(.horizontal, 12)
    }
}

#Preview {
    OptometryFormView()
        .preferredColorScheme(.dark)
}
