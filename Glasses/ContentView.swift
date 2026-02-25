import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var viewModel = OptometryViewModel()

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
                                ProtractorView(axisValue: viewModel.odActiveAxis, isOS: false)
                                    .frame(height: 160)
                                Text("OD")
                                    .font(.title)
                            }
                            
                            VStack(spacing: 6) {
                                Text("PD")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 2) {
                                    TextField("63", text: $viewModel.prescription.pd)
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
                            }
                            .padding(.top, 50)
                            
                            VStack {
                                ProtractorView(axisValue: viewModel.osActiveAxis, isOS: true)
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
        }
    }
}

#Preview {
    ContentView()
}
