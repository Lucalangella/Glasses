import SwiftUI

struct TaboAxisView: View {
    @Binding var odAxis: String
    @Binding var osAxis: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. HIG Compliant Section Header (Aligned to leading edge)
            Text("Tabo Axis")
                .font(.headline)
                .padding(.horizontal, 4)
            
            // 2. Grouped Card Background
            HStack(spacing: 16) {
                // OD Protractor
                VStack {
                    ProtractorView(axisText: $odAxis, isOS: false)
                        .frame(height: 140)
                    Text("OD")
                        .font(.title3.weight(.semibold))
                }
                
                // OS Protractor
                VStack {
                    ProtractorView(axisText: $osAxis, isOS: true)
                        .frame(height: 140)
                    Text("OS")
                        .font(.title3.weight(.semibold))
                }
            }
            .padding(.vertical, 40)
            .padding(.horizontal, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var odAxis = "90"
        @State private var osAxis = "85"
        
        var body: some View {
            TaboAxisView(odAxis: $odAxis, osAxis: $osAxis)
                .padding(.vertical)
                .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    return PreviewWrapper()
}
