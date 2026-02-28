import SwiftUI
import ARKit

struct TaboPDView: View {
    @Binding var pdValue: String
    @Binding var isShowingScanner: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 1. HIG Compliant Section Header (Aligned to leading edge)
            Text("Pupillary Distance")
                .font(.headline)
                .padding(.horizontal, 4)
            
            // 2. Grouped Card Background
            VStack(spacing: 12) {
                Text("PD")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.secondary)
                
                // Stacked vertically to prevent horizontal squishing on smaller iPhones
                VStack(spacing: 12) {
                    HStack(spacing: 2) {
                        TextField("63.0", text: $pdValue)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.center)
                            .frame(width: 44)
                        
                        Text("mm")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 10)
                    // Use tertiary background so the text field pops against the card
                    .background(Color(UIColor.tertiarySystemGroupedBackground))
                    .cornerRadius(12)
                    
                    // THE AR SCANNER BUTTON
                    if ARFaceTrackingConfiguration.isSupported {
                        Button(action: {
                            isShowingScanner = true
                        }) {
                            Image(systemName: "faceid")
                                .font(.title3)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.accentColor)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                        // Subtle shadow to make the CTA pop
                        .shadow(color: Color.accentColor.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
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
        @State private var pdValue = "63.0"
        @State private var isShowingScanner = false
        
        var body: some View {
            TaboPDView(
                pdValue: $pdValue,
                isShowingScanner: $isShowingScanner
            )
            .padding(.vertical)
            .background(Color(UIColor.systemGroupedBackground))
        }
    }
    
    return PreviewWrapper()
}
