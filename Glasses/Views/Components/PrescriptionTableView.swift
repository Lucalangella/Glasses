import SwiftUI

struct PrescriptionTableView: View {
    @Binding var odSphere: String
    @Binding var odCyl: String
    @Binding var odAxis: String
    
    @Binding var osSphere: String
    @Binding var osCyl: String
    @Binding var osAxis: String
    
    enum ActiveScaleField: Equatable {
        case odSphere, odCyl, odAxis
        case osSphere, osCyl, osAxis
    }
    @State private var activeField: ActiveScaleField? = nil
    
    // 1. ADDED A NAMESPACE FOR THE SLIDING ANIMATION
    @Namespace private var segmentAnimation
    
    var onToggleSign: (EyeType, FieldType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            eyeSection(
                title: "Right Eye (OD)",
                sph: $odSphere, cyl: $odCyl, axis: $odAxis,
                sphereId: .odSphere, cylId: .odCyl, axisId: .odAxis
            )
            
            eyeSection(
                title: "Left Eye (OS)",
                sph: $osSphere, cyl: $osCyl, axis: $osAxis,
                sphereId: .osSphere, cylId: .osCyl, axisId: .osAxis
            )
        }
        .padding(.horizontal)
        .animation(.spring(response: 0.25, dampingFraction: 1.0), value: activeField)
    }
    
    private func eyeSection(title: String, sph: Binding<String>, cyl: Binding<String>, axis: Binding<String>, sphereId: ActiveScaleField, cylId: ActiveScaleField, axisId: ActiveScaleField) -> some View {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.headline)
                
                HStack(spacing: 0) {
                    // 1. Add Anchor to SPH
                    fieldSelectorButton(title: "SPH", text: sph.wrappedValue, isActive: activeField == sphereId) {
                        toggleActiveField(sphereId)
                    }
                    .walkthroughAnchor(sphereId == .odSphere ? "sph_button" : nil)
                    
                    verticalDivider()
                    
                    // 2. Add Anchor to CYL
                    fieldSelectorButton(title: "CYL", text: cyl.wrappedValue, isActive: activeField == cylId) {
                        toggleActiveField(cylId)
                    }
                    .walkthroughAnchor(cylId == .odCyl ? "cyl_button" : nil)
                    
                    verticalDivider()
                    
                    // 3. Add Anchor to AXIS
                    fieldSelectorButton(title: "AXIS", text: axis.wrappedValue, isActive: activeField == axisId) {
                        toggleActiveField(axisId)
                    }
                    .walkthroughAnchor(axisId == .odAxis ? "axis_button" : nil)
                }
                .padding(6)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                
                // The Inline Selectors (Rulers)
                if activeField == sphereId {
                    VisualRulerScaleView(value: doubleBinding(for: sph))
                        .padding(.top, 4)
                        .transition(.opacity)
                        .walkthroughAnchor(sphereId == .odSphere ? "sph_ruler" : nil)
                } else if activeField == cylId {
                    VisualRulerScaleView(value: doubleBinding(for: cyl))
                        .padding(.top, 4)
                        .transition(.opacity)
                        .walkthroughAnchor(cylId == .odCyl ? "cyl_ruler" : nil)
                } else if activeField == axisId {
                    AxisRulerScaleView(value: axisDoubleBinding(for: axis))
                        .padding(.top, 4)
                        .transition(.opacity)
                        .walkthroughAnchor(axisId == .odAxis ? "axis_ruler" : nil)
                }
            }
        }
    
    // MARK: - Components
    
    private func fieldSelectorButton(title: String, text: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            action()
        }) {
            VStack(alignment: .center, spacing: 4) { // Changed to center alignment for a cleaner look
                Text(title)
                    .font(.caption2.weight(.bold))
                    .foregroundColor(isActive ? .accentColor : .secondary)
                
                Text(text.isEmpty ? (title == "AXIS" ? "0" : "0.00") : text)
                    .font(.body.weight(isActive ? .semibold : .regular))
                    .foregroundColor(isActive ? .primary : .primary.opacity(0.6))
                    .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 10)
            .contentShape(Rectangle())
            // 3. THE SLIDING HIGHLIGHT BACKGROUND
            .background(
                ZStack {
                    if isActive {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(UIColor.tertiarySystemGroupedBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                            // matchedGeometryEffect creates the smooth sliding animation between tabs
                            .matchedGeometryEffect(id: "activeTabBackground", in: segmentAnimation, isSource: true)
                    }
                }
            )
        }
        // 4. ADDED TACTILE BUTTON STYLE
        .buttonStyle(SegmentButtonStyle())
    }
    
    private func verticalDivider() -> some View {
        Divider()
            .frame(height: 24)
            .padding(.horizontal, 4)
            .opacity(0.5)
    }
    
    // MARK: - Logic
    
    private func toggleActiveField(_ field: ActiveScaleField) {
        if activeField == field {
            activeField = nil
        } else {
            activeField = field
        }
    }
    
    // Binding for SPH and CYL (+/- 0.25 steps)
    private func doubleBinding(for textBinding: Binding<String>) -> Binding<Double> {
        Binding<Double>(
            get: {
                Double(textBinding.wrappedValue.replacingOccurrences(of: "+", with: "")) ?? 0.0
            },
            set: { newValue in
                if newValue == 0 {
                    textBinding.wrappedValue = "0.00"
                } else {
                    textBinding.wrappedValue = String(format: "%+.2f", newValue)
                }
            }
        )
    }
    
    // Binding for AXIS (Whole numbers 0-180)
    private func axisDoubleBinding(for textBinding: Binding<String>) -> Binding<Double> {
        Binding<Double>(
            get: {
                Double(textBinding.wrappedValue) ?? 0.0
            },
            set: { newValue in
                textBinding.wrappedValue = String(format: "%.0f", newValue)
            }
        )
    }
}

// MARK: - Custom Button Style
// Provides the tactile "squish" when tapping a segment
struct SegmentButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
