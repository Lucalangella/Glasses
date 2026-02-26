import SwiftUI

struct FramesGridView: View {
    var recommendedFrames: Set<String>
    var recommendationReasons: [String]
    
    private let allFrames = [
        "aviator", "browline", "cateye",
        "geometric", "oval", "oversized",
        "rectangle", "round", "square"
    ]
    
    // Always show all frames — never remove items so the grid height stays constant.
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
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
            
            let joinedReasons = recommendationReasons.joined(separator: " and your ")
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(.accentColor)
                    Text("Optical Recommendation")
                        .font(.subheadline.bold())
                        .foregroundColor(.accentColor)
                }

                Text("Based on your \(joinedReasons), these frames are curated to optimize your visual clarity. Smaller, rounded shapes help center your pupils and significantly reduce lens edge thickness and peripheral distortion.")
                    .font(.caption)
                    .lineSpacing(4)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color.accentColor.opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
            .opacity(recommendationReasons.isEmpty ? 0 : 1)
            .animation(.easeInOut(duration: 0.2), value: recommendationReasons.isEmpty)
            
            // MARK: - Grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(allFrames, id: \.self) { frameName in
                    let isRecommended = !recommendedFrames.isEmpty && recommendedFrames.contains(frameName)
                    let isDimmed = !recommendedFrames.isEmpty && !recommendedFrames.contains(frameName)
                    
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
                    .opacity(isDimmed ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 0.25), value: isDimmed)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
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
