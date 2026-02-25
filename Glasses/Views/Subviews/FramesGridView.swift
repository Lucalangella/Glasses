import SwiftUI

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
                Text("Frame Styles")
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


