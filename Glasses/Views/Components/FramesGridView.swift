import SwiftUI

struct FramesGridView: View {
    var recommendedFrames: Set<String>
    
    private let allFrames = [
        "aviator", "browline", "cateye",
        "geometric", "oval", "oversized",
        "rectangle", "round", "square"
    ]
    
    private var displayedFrames: [String] {
        if recommendedFrames.isEmpty {
            return allFrames
        } else {
            return allFrames.filter { recommendedFrames.contains($0) }
        }
    }
    
    // MARK: - Dynamic Columns
    // Takes up to 3 columns, but scales down to 1 or 2 to fill the width if fewer frames are shown
    private var columns: [GridItem] {
        let activeCount = max(1, min(displayedFrames.count, 3))
        return Array(repeating: GridItem(.flexible(), spacing: 16), count: activeCount)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            // MARK: - Header
            HStack {
                Text(recommendedFrames.isEmpty ? "All Frame Styles" : "Recommended Styles")
                    .font(.headline)
                    .foregroundColor(recommendedFrames.isEmpty ? .secondary : .accentColor)
                
                Spacer()
                
                if !recommendedFrames.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                        Text("Filtered by Rx")
                    }
                    .font(.caption.weight(.bold))
                    .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)
            
            // MARK: - Grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(displayedFrames, id: \.self) { frameName in
                    let isRecommended = !recommendedFrames.isEmpty
                    
                    NavigationLink(value: frameName) {
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Image(frameName)
                                    .resizable()
                                    .scaledToFit()
                                    // Flex height so they look good when taking up 50% or 100% of the screen width
                                    .frame(minHeight: 40, maxHeight: 60)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    // 1. ADDED SHADOW FOR DEPTH
                                    .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 3)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isRecommended ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 2)
                                    )
                                
                                if isRecommended {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                        .padding(4)
                                        .background(Color.accentColor)
                                        .clipShape(Circle())
                                        .offset(x: 6, y: -6)
                                        // Optional: Add a tiny shadow to the badge too
                                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                                }
                            }
                            
                            Text(frameName.capitalized.replacingOccurrences(of: "_", with: " "))
                                .font(.caption2)
                                .fontWeight(isRecommended ? .bold : .medium)
                                .foregroundColor(.primary)
                        }
                    }
                    // 2. REPLACED .plain WITH CUSTOM BUTTON STYLE
                    .buttonStyle(CardButtonStyle())
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8) // Added a bit of bottom padding so the shadow isn't clipped
            .animation(.spring(response: 0.4, dampingFraction: 0.75), value: displayedFrames)
        }
    }
}

// MARK: - Custom Button Style
// This creates the tactile "squish" effect when the user presses the frame
struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // Scale down slightly when pressed
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            // Dim slightly when pressed
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            // Smooth bouncy animation for the interaction
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
