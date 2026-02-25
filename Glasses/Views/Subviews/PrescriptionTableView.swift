import SwiftUI

struct PrescriptionTableView: View {
    @Binding var odSphere: String
    @Binding var odCyl: String
    @Binding var odAxis: String
    
    @Binding var osSphere: String
    @Binding var osCyl: String
    @Binding var osAxis: String
    
    var onToggleSign: (OptometryViewModel.EyeType, OptometryViewModel.FieldType) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            eyeSection(title: "Right Eye (OD)", sph: $odSphere, cyl: $odCyl, axis: $odAxis, eye: .od)
            eyeSection(title: "Left Eye (OS)", sph: $osSphere, cyl: $osCyl, axis: $osAxis, eye: .os)
        }
        .padding(.horizontal)
    }
    
    private func eyeSection(title: String, sph: Binding<String>, cyl: Binding<String>, axis: Binding<String>, eye: OptometryViewModel.EyeType) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
            
            HStack(spacing: 0) {
                inputColumn(title: "SPH", placeholder: "0.00", text: sph, hasSignToggle: true, eye: eye, field: .sphere)
                verticalDivider()
                inputColumn(title: "CYL", placeholder: "0.00", text: cyl, hasSignToggle: true, eye: eye, field: .cylinder)
                verticalDivider()
                inputColumn(title: "AXIS", placeholder: "0", text: axis, isAxis: true, eye: eye, field: .sphere) // Field doesn't matter for axis sign toggle as it doesn't have one
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
        }
    }
    
    private func inputColumn(title: String, placeholder: String, text: Binding<String>, isAxis: Bool = false, hasSignToggle: Bool = false, eye: OptometryViewModel.EyeType, field: OptometryViewModel.FieldType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                if hasSignToggle {
                    Button(action: {
                        onToggleSign(eye, field)
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
    
    private func verticalDivider() -> some View {
        Divider()
            .frame(height: 36)
            .padding(.horizontal, 12)
    }
}
