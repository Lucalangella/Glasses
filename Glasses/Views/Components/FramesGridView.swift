import SwiftUI

struct FramesGridView: View {
    var recommendedFrames: Set<String>
    var recommendationReasons: [String]       // kept for legacy compatibility
    var recommendationTitles: [String] = []   // NEW: short chip labels
    var recommendationSummary: String = ""   // NEW: pre-built blurb

    private let allFrames = [
        "aviator", "browline", "cateye",
        "geometric", "oval", "oversized",
        "rectangle", "round", "square"
    ]

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // MARK: - Header
            HStack {
                Text("Frames")
                    .font(.headline)

                Spacer()

                if !recommendationTitles.isEmpty {
                    // Show individual rule chips when there are 1–2 rules,
                    // otherwise fall back to a single generic chip.
                    if recommendationTitles.count <= 2 {
                        HStack(spacing: 4) {
                            ForEach(recommendationTitles, id: \.self) { title in
                                ruleChip(title)
                            }
                        }
                    } else {
                        ruleChip("\(recommendationTitles.count) Rules")
                    }
                }
            }
            .padding(.horizontal)

            // MARK: - Grid
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(allFrames, id: \.self) { frameName in
                    let isRecommended = recommendedFrames.contains(frameName)
                    let isDimmed = !recommendationTitles.isEmpty && !recommendedFrames.contains(frameName)

                    NavigationLink(value: frameName) {
                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Image(frameName)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(minHeight: 40, maxHeight: 60)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
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
                                        .shadow(color: Color.black.opacity(0.15), radius: 2, x: 0, y: 1)
                                }
                            }

                            Text(frameName.capitalized.replacingOccurrences(of: "_", with: " "))
                                .font(.caption2)
                                .fontWeight(isRecommended ? .bold : .medium)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(CardButtonStyle())
                    .opacity(isDimmed ? 0.35 : 1.0)
                    .animation(.easeInOut(duration: 0.25), value: isDimmed)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)

            // MARK: - Info Blurb (always visible)
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: recommendationTitles.isEmpty ? "checkmark.seal.fill" : "info.circle.fill")
                        .foregroundColor(recommendationTitles.isEmpty ? .green : .accentColor)
                    Text(recommendationTitles.isEmpty ? "All Frames Suitable" : "Optical Recommendation")
                        .font(.subheadline.bold())
                        .foregroundColor(recommendationTitles.isEmpty ? .green : .accentColor)
                }

                Text(recommendationSummary ?? legacySummary ?? "")
                    .font(.caption)
                    .lineSpacing(4)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background((recommendationTitles.isEmpty ? Color.green : Color.accentColor).opacity(0.05))
            .cornerRadius(12)
            .padding(.horizontal)
            .animation(.easeInOut(duration: 0.2), value: recommendationTitles.isEmpty)
        }
    }

    // MARK: - Helpers

    /// Falls back to the legacy joined-reasons string when the new summary isn't passed in.
    private var legacySummary: String? {
        guard !recommendationReasons.isEmpty else { return nil }
        let joined = recommendationReasons.joined(separator: " and your ")
        return "Based on your \(joined), these frames are curated to optimise your visual clarity. Smaller, rounded shapes help centre your pupils and significantly reduce lens edge thickness and peripheral distortion."
    }

    @ViewBuilder
    private func ruleChip(_ label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "sparkles")
            Text(label)
        }
        .font(.caption.weight(.bold))
        .foregroundColor(.accentColor)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.accentColor.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Custom Button Style

struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
