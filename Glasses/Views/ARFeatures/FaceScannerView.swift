import SwiftUI
import ARKit
import SceneKit

// MARK: - Main View
struct FaceScannerView: View {
    @Binding var isPresented: Bool
    @Binding var finalPD: String
    
    // 1. Look how clean this is! All state is now managed by the ViewModel.
    @StateObject private var viewModel = FaceScannerViewModel()
    
    var body: some View {
        ZStack {
            // 2. The AR Engine now just takes the ViewModel and reports data to it
            ARFaceTrackingEngine(viewModel: viewModel)
                .ignoresSafeArea()
            
            // Top Bar (Close Button & Progress)
            VStack {
                HStack {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                            .padding(12)
                    }
                    Spacer()
                }
                .padding(.top, 50)
                .padding(.leading, 16)
                
                if viewModel.state == .scanning || viewModel.state == .processing {
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.3), lineWidth: 4)
                                .frame(width: 50, height: 50)
                            
                            Circle()
                                .trim(from: 0, to: viewModel.progress)
                                .stroke(Color.white, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                                .animation(.linear(duration: 0.1), value: viewModel.progress)
                        }
                        
                        Text(viewModel.statusText)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.top, 4)
                    }
                    .transition(.opacity)
                }
                
                Spacer()
            }
            
            // Bottom Sheets
            VStack {
                Spacer()
                
                if viewModel.state == .intro {
                    // 3. The view passes simple actions to the ViewModel
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
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: viewModel.state)
    }
}
