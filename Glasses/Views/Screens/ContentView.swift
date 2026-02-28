import SwiftUI
import Combine
import ARKit

struct ContentView: View {
    @StateObject private var viewModel = OptometryViewModel()
    @State private var isShowingScanner = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    // MARK: - Welcome Header
                    VStack(spacing: 8) {
                        Text("Your Prescription, Decoded.")
                            .font(.title2.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        Text("Enter your numbers below — Clarity will recommend the best frames and lenses for your eyes.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // MARK: - Prescription Input
                    PrescriptionTableView(
                        odSphere: $viewModel.prescription.od.sphere,
                        odCyl: $viewModel.prescription.od.cylinder,
                        odAxis: $viewModel.prescription.od.axis,
                        osSphere: $viewModel.prescription.os.sphere,
                        osCyl: $viewModel.prescription.os.cylinder,
                        osAxis: $viewModel.prescription.os.axis,
                        onToggleSign: { eye, field in
                            viewModel.toggleSign(eye: eye, field: field)
                        }
                    )
                    
                    // MARK: - Axis & PD
                    TaboMeasurementView(
                        odAxis: $viewModel.prescription.od.axis,
                        osAxis: $viewModel.prescription.os.axis,
                        pdValue: $viewModel.prescription.pd,
                        isShowingScanner: $isShowingScanner
                    )
                    
                    // MARK: - Lens Thickness Visualization
                    LensVisualizationView(prescription: $viewModel.prescription)
                    
                    
                    // MARK: - Frame Recommendations
                    FramesGridView(
                        recommendedFrames: viewModel.recommendedFrames,
                        recommendationReasons: viewModel.recommendationReasons
                    )
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Clarity")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: AboutView()) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: PrescriptionGuideView()) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .navigationDestination(for: String.self) { frameName in
                Glasses3DView(frameName: frameName)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .fullScreenCover(isPresented: $isShowingScanner) {
                FaceScannerView(
                    isPresented: $isShowingScanner,
                    finalPD: $viewModel.prescription.pd
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
