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
                    
                    FramesGridView(recommendedFrames: viewModel.recommendedFrames)
                        .padding(.top, 16)
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        Text("Tabo")
                            .font(.title3)
                            .padding(.trailing, 8)
                        
                        HStack(spacing: 16) {
                            VStack {
                                ProtractorView(axisText: $viewModel.prescription.od.axis, isOS: false)
                                    .frame(height: 160)
                                Text("OD")
                                    .font(.title)
                            }
                            
                            VStack(spacing: 6) {
                                Text("Pupillary Distance (PD)")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 8) {
                                    HStack(spacing: 2) {
                                        TextField("63.0", text: $viewModel.prescription.pd)
                                            .keyboardType(.decimalPad)
                                            .multilineTextAlignment(.center)
                                            .frame(width: 44)
                                        
                                        Text("mm")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 10)
                                    .background(Color(UIColor.secondarySystemGroupedBackground))
                                    .cornerRadius(12)
                                    
                                    // THE AR SCANNER BUTTON
                                    if ARFaceTrackingConfiguration.isSupported {
                                        Button(action: {
                                            isShowingScanner = true
                                        }) {
                                            Image(systemName: "faceid")
                                                .font(.title2)
                                                .foregroundColor(.accentColor)
                                                .padding(8)
                                                .background(Color.accentColor.opacity(0.1))
                                                .cornerRadius(10)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(.top, 50)
                            
                            VStack {
                                ProtractorView(axisText: $viewModel.prescription.os.axis, isOS: true)
                                    .frame(height: 160)
                                Text("OS")
                                    .font(.title)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
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
