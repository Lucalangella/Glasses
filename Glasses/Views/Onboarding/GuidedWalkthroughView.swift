import SwiftUI

// MARK: - Walkthrough Step Definition

struct WalkthroughStep {
    let id: String
    let title: String
    let body: String
    let icon: String
    /// The task label shown while the step is incomplete.
    let task: String?
    /// When true, the "Next" button stays disabled until the task is done.
    let requiresCompletion: Bool
}

// MARK: - Anchor Preference Key

struct WalkthroughAnchorKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

// MARK: - View Extension

extension View {
    func walkthroughAnchor(_ id: String) -> some View {
        self.anchorPreference(key: WalkthroughAnchorKey.self, value: .bounds) { [id: $0] }
    }
}

// MARK: - Walkthrough Overlay

struct WalkthroughOverlay: View {
    let steps: [WalkthroughStep]
    let anchors: [String: Anchor<CGRect>]
    let proxy: GeometryProxy
    @Binding var currentStepIndex: Int
    @Binding var isActive: Bool
    @Binding var stepCompleted: Bool
    var scrollProxy: ScrollViewProxy?
    
    private var currentStep: WalkthroughStep? {
        guard steps.indices.contains(currentStepIndex) else { return nil }
        return steps[currentStepIndex]
    }
    
    private var currentRect: CGRect? {
        guard let step = currentStep, let anchor = anchors[step.id] else { return nil }
        return proxy[anchor]
    }
    
    private var cutoutRect: CGRect? {
        guard let rect = currentRect else { return nil }
        return rect.insetBy(dx: 8, dy: -10)
    }
    
    var body: some View {
        if let step = currentStep {
            ZStack(alignment: .bottom) {
                
                // 1 — Dim layer with interactive cutout
                InteractiveDimOverlay(cutoutRect: cutoutRect)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 0.4), value: currentStepIndex)
                
                // 2 — Highlighted section border glow
                if let rect = cutoutRect {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.blue.opacity(0.5), lineWidth: 2)
                        .frame(width: rect.width, height: rect.height)
                        .position(x: rect.midX, y: rect.midY)
                        .allowsHitTesting(false)
                        .animation(.easeInOut(duration: 0.4), value: currentStepIndex)
                }
                
                // 3 — Bottom-pinned card
                explanationCard(for: step)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.45, dampingFraction: 0.85), value: currentStepIndex)
                    .animation(.easeInOut(duration: 0.25), value: stepCompleted)
            }
        }
    }
    
    // MARK: - Bottom Card
    
    private func explanationCard(for step: WalkthroughStep) -> some View {
        VStack(spacing: 0) {
            // Drag handle
            Capsule()
                .fill(Color.secondary.opacity(0.4))
                .frame(width: 36, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 14)
            
            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(.blue
                                .opacity(0.15))
                            .frame(width: 40, height: 40)
                        Image(systemName: step.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Step \(currentStepIndex + 1) of \(steps.count)")
                            .font(.caption2.weight(.bold))
                            .foregroundColor(.blue)
                            .textCase(.uppercase)
                        
                        Text(step.title)
                            .font(.headline)
                    }
                    
                    Spacer()
                }
                
                // Description
                Text(step.body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Task progress indicator
                if step.requiresCompletion {
                    HStack(spacing: 8) {
                        Image(systemName: stepCompleted ? "checkmark.circle.fill" : "hand.tap")
                            .foregroundColor(stepCompleted ? .green : .blue)
                            .font(.body.weight(.semibold))
                            .contentTransition(.symbolEffect(.replace))
                        
                        Text(stepCompleted ? "Done! Tap Next to continue." : (step.task ?? "Try it out above"))
                            .font(.caption.weight(.medium))
                            .foregroundColor(stepCompleted ? .green : .primary.opacity(0.7))
                    }
                    .padding(.vertical, 10)
                    .padding(.horizontal, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                stepCompleted ? Color.green
                                    .opacity(0.1) : Color.blue
                                    .opacity(0.08)
                            )
                    )
                }
                
                // Navigation
                HStack {
                    
                    Spacer()
                    
                    // Dots
                    HStack(spacing: 5) {
                        ForEach(0..<steps.count, id: \.self) { i in
                            Circle()
                                .fill(
                                    i <= currentStepIndex ? Color.blue : Color.secondary
                                        .opacity(0.25)
                                )
                                .frame(width: 6, height: 6)
                        }
                    }
                    
                    Spacer()
                    
                    let isLast = currentStepIndex == steps.count - 1
                    let canAdvance = !step.requiresCompletion || stepCompleted
                    
                    Button(action: advance) {
                        Text(isLast ? "Get Started" : "Next")
                            .font(.subheadline.weight(.bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(
                                canAdvance ? Color.blue : Color.gray
                                    .opacity(0.35)
                            )
                            .cornerRadius(20)
                    }
                    .disabled(!canAdvance)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34)
        }
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.regularMaterial)
                .shadow(color: .black.opacity(0.12), radius: 20, x: 0, y: -5)
        )
        .padding(.horizontal, 8)
    }
    
    // MARK: - Actions
    
    private func advance() {
        guard !(currentStep?.requiresCompletion ?? false) || stepCompleted else { return }
        
        if currentStepIndex < steps.count - 1 {
            let nextIndex = currentStepIndex + 1
            
            withAnimation(.spring(response: 0.45, dampingFraction: 0.85)) {
                currentStepIndex = nextIndex
                stepCompleted = false
            }
            
            // Scroll the next step's anchor into view
            if let nextStep = steps[safe: nextIndex] {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scrollProxy?.scrollTo(nextStep.id, anchor: .center)
                    }
                }
            }
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                isActive = false
            }
        }
    }
}

// MARK: - Interactive Dim Overlay (UIKit)
/// Dims the entire screen but lets touches pass through inside the cutout rect,
/// so the user can interact with the highlighted section.

struct InteractiveDimOverlay: UIViewRepresentable {
    var cutoutRect: CGRect?
    
    func makeUIView(context: Context) -> PassthroughDimView {
        let view = PassthroughDimView()
        view.backgroundColor = .clear
        view.isOpaque = false
        return view
    }
    
    func updateUIView(_ uiView: PassthroughDimView, context: Context) {
        uiView.cutoutRect = cutoutRect
        uiView.setNeedsDisplay()
    }
}

class PassthroughDimView: UIView {
    var cutoutRect: CGRect?
    
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        
        // Full-screen dim
        ctx.setFillColor(UIColor.black.withAlphaComponent(0.55).cgColor)
        ctx.fill(rect)
        
        // Clear the cutout
        if let cutout = cutoutRect {
            let path = UIBezierPath(roundedRect: cutout, cornerRadius: 20)
            ctx.setBlendMode(.clear)
            ctx.addPath(path.cgPath)
            ctx.fillPath()
        }
    }
    
    /// Touches inside the cutout pass through; touches on the dim are consumed.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if let cutout = cutoutRect, cutout.contains(point) {
            return false
        }
        return true
    }
}

// MARK: - Safe Array Access

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
