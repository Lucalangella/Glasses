import SwiftUI
import Combine
import ARKit

struct ContentView: View {
    @StateObject private var viewModel = OptometryViewModel()
    
    // Just ONE state variable needed now!
    @State private var isShowingScanner = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    
                    FramesGridView(
                        recommendedFrames: viewModel.recommendedFrames,
                        recommendationReasons: viewModel.recommendationReasons
                    )
                    .padding(.top, 16)
                    
                    // Lens Materials & Visualization - immediately after frames
                    LensVisualizationView(prescription: $viewModel.prescription)
                        .padding(.top, 8)
                    
                    TaboMeasurementView(
                        odAxis: $viewModel.prescription.od.axis,
                        osAxis: $viewModel.prescription.os.axis,
                        pdValue: $viewModel.prescription.pd,
                        isShowingScanner: $isShowingScanner
                    )

                    
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
                }
                .padding(.vertical)
            }
            .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
            .navigationTitle("Clarity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
            // THE FULL SCREEN AR SCANNER
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
