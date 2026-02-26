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
    
    var onToggleSign: (OptometryViewModel.EyeType, OptometryViewModel.FieldType) -> Void
    
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
        .animation(.easeInOut(duration: 0.2), value: activeField)
    }
    
    private func eyeSection(title: String, sph: Binding<String>, cyl: Binding<String>, axis: Binding<String>, sphereId: ActiveScaleField, cylId: ActiveScaleField, axisId: ActiveScaleField) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
            
            // The Main Input Row
            HStack(spacing: 0) {
                // SPH Button
                fieldSelectorButton(title: "SPH", text: sph.wrappedValue, isActive: activeField == sphereId) {
                    toggleActiveField(sphereId)
                }
                
                verticalDivider()
                
                // CYL Button
                fieldSelectorButton(title: "CYL", text: cyl.wrappedValue, isActive: activeField == cylId) {
                    toggleActiveField(cylId)
                }
                
                verticalDivider()
                
                // AXIS Button
                fieldSelectorButton(title: "AXIS", text: axis.wrappedValue, isActive: activeField == axisId) {
                    toggleActiveField(axisId)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            
            // The Inline Selectors
                        if activeField == sphereId {
                            VisualRulerScaleView(value: doubleBinding(for: sph))
                                .padding(.top, 4)
                        } else if activeField == cylId {
                            VisualRulerScaleView(value: doubleBinding(for: cyl))
                                .padding(.top, 4)
                        } else if activeField == axisId {
                            AxisRulerScaleView(value: axisDoubleBinding(for: axis))
                                .padding(.top, 4)
                        }
        }
    }
    
    // MARK: - Components
    
    private func fieldSelectorButton(title: String, text: String, isActive: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            action()
        }) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(isActive ? .accentColor : .secondary)
                
                Text(text.isEmpty ? (title == "AXIS" ? "0" : "0.00") : text)
                    .font(.body)
                    .foregroundColor(text.isEmpty ? .secondary.opacity(0.5) : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .padding(-8)
        .padding(8)
        .background(isActive ? Color.accentColor.opacity(0.1) : Color.clear)
        .cornerRadius(8)
    }
    
    private func verticalDivider() -> some View {
        Divider()
            .frame(height: 36)
            .padding(.horizontal, 12)
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
