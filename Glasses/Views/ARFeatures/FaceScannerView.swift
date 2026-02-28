import SwiftUI
import ARKit

struct FaceScannerView: View {
    @Binding var isPresented: Bool
    @Binding var finalPD: String
    
    @StateObject private var viewModel = FaceScannerViewModel()
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background AR View
                ARFaceTrackingEngine(viewModel: viewModel)
                    .ignoresSafeArea()
                
                // Top Close Button
                VStack {
                    HStack {
                        Button(action: { isPresented = false }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                                .padding(12)
                                .background(Circle().fill(Color.black.opacity(0.3)))
                        }
                        Spacer()
                    }
                    .padding(.top, geo.safeAreaInsets.top > 0 ? 16 : 40)
                    .padding(.leading, 16)
                    
                    Spacer()
                }
                
                // Active UI Overlay
                if isScanningActive(viewModel.state) {
                    dotAndTextOverlay(in: geo)
                }
                
                // Bottom Sheets
                VStack {
                    Spacer()
                    
                    if viewModel.state == .intro {
                        IntroSheetView(onStart: { viewModel.startScan() })
                            .transition(.move(edge: .bottom))
                    } else if viewModel.state == .results {
                        ResultsSheetView(
                            results: viewModel.scanResults,
                            onContinue: {
                                finalPD = String(format: "%.1f", viewModel.scanResults.pd)
                                isPresented = false
                            },
                            onRescan: {
                                viewModel.resetScan()
                            }
                        )
                        .transition(.move(edge: .bottom))
                    }
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.state)
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
        private func dotAndTextOverlay(in geo: GeometryProxy) -> some View {
            // Define coordinates
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            // Push it near the top safe area (close to the physical camera lens)
            let topCenter = CGPoint(x: geo.size.width / 2, y: geo.safeAreaInsets.top + 50)
            
            let isCentered = (viewModel.state == .focusCenter)
            let dotPosition = isCentered ? center : topCenter
            
            ZStack {
                // 1. The Dot
                Circle()
                    .stroke(dotColor(for: viewModel.state), lineWidth: 4)
                    .frame(width: 50, height: 50)
                
                // 2. The Progress Ring (Only shows when measuring)
                if viewModel.state == .measuring || viewModel.state == .processing {
                    Circle()
                        .trim(from: 0, to: viewModel.progress)
                        .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: viewModel.progress)
                }
                
                // 3. NEW: The Success Checkmark
                if viewModel.state == .processing {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.green)
                        // A white background behind the checkmark ensures the hollow ring is fully hidden
                        .background(Circle().fill(Color.white).frame(width: 48, height: 48))
                        // Adds a satisfying "pop" animation when it appears
                        .transition(.scale(scale: 0.5).combined(with: .opacity))
                }
                
                // 4. The Instruction Text
                Text(viewModel.statusText)
                    .font(.headline)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.ultraThinMaterial)
                    .environment(\.colorScheme, .dark)
                    .cornerRadius(12)
                    // Keep the text consistently spaced below the dot
                    .offset(y: 60)
                    .id(viewModel.statusText) // Forces transition on text change
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
            .position(dotPosition)
            // Smoothly animate the dot flying from center to top, and the checkmark popping in
            .animation(.spring(response: 0.5, dampingFraction: 0.7), value: viewModel.state)
            .animation(.easeInOut(duration: 1.0), value: dotPosition)
        }
    
    // MARK: - Helpers
    
    private func isScanningActive(_ state: ScanState) -> Bool {
        return state != .intro && state != .results
    }
    
    private func dotColor(for state: ScanState) -> Color {
        switch state {
        case .focusCenter, .followDot:
            return .white
        case .measuring, .processing:
            return .white.opacity(0.3) // Dims the hollow dot so the green progress ring pops
        default:
            return .clear
        }
    }
}
