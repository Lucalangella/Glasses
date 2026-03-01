//
//  ContentView.swift
//  Glasses
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollProxy in
                ScrollView {
                    VStack(spacing: 32) {
                        // MARK: - Welcome Header
                        VStack(spacing: 8) {
                            Text("Your Prescription, Decoded.")
                                .font(.title2.weight(.bold))
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Text("Enter your numbers below. Clarity will recommend the best frames and lenses for your eyes.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)

                        // MARK: - Prescription Input
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 0).id("sph")
                            Color.clear.frame(height: 0).id("cyl")
                            Color.clear.frame(height: 0).id("axis")

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

                        // MARK: - Axis & PD
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 0).id("pd_step")

                            TaboMeasurementView(
                                odAxis: $viewModel.prescription.od.axis,
                                osAxis: $viewModel.prescription.os.axis,
                                pdValue: $viewModel.prescription.pd,
                                isShowingScanner: $viewModel.isShowingScanner
                            )
                        }

                        // MARK: - Lens Thickness Visualization
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 0).id("lens_od")

                            LensVisualizationView(
                                prescription: $viewModel.prescription,
                                onLensIndexChanged: {
                                    withAnimation {
                                        viewModel.handleLensIndexChanged()
                                    }
                                }
                            )
                        }

                        // MARK: - Frame Recommendations
                        VStack(spacing: 0) {
                            Color.clear.frame(height: 0).id("frames")

                            FramesGridView(
                                recommendedFrames: viewModel.recommendedFrames,
                                recommendationReasons: viewModel.recommendationReasons,
                                recommendationTitles: viewModel.recommendationTitles,
                                recommendationSummary: viewModel.recommendationSummary
                            )
                            .id("frames")
                            .walkthroughAnchor("frames")
                        }
                        .padding(.vertical)
                        .padding(.bottom, viewModel.isWalkthroughActive ? 300 : 0)
                    }
                }
                .scrollDisabled(viewModel.isWalkthroughActive)
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("Clarity")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.resetWalkthrough()

                            withAnimation(.easeInOut(duration: 0.5)) {
                                scrollProxy.scrollTo("sph", anchor: .center)
                            }

                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation {
                                    viewModel.activateWalkthrough()
                                }
                            }
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.accentColor)
                        }
                        .disabled(viewModel.isWalkthroughActive)
                    }
                }
                .navigationDestination(for: String.self) { frameName in
                    Glasses3DView(frameName: frameName)
                }
                .onTapGesture {
                    if !viewModel.isWalkthroughActive {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .fullScreenCover(isPresented: $viewModel.isShowingScanner) {
                    FaceScannerView(
                        isPresented: $viewModel.isShowingScanner,
                        finalPD: $viewModel.prescription.pd
                    )
                }

                // MARK: - Walkthrough Overlay
                .overlayPreferenceValue(WalkthroughAnchorKey.self) { anchors in
                    GeometryReader { geo in
                        if viewModel.isWalkthroughActive {
                            WalkthroughOverlay(
                                steps: viewModel.walkthroughSteps,
                                anchors: anchors,
                                proxy: geo,
                                currentStepIndex: $viewModel.walkthroughStep,
                                isActive: $viewModel.isWalkthroughActive,
                                stepCompleted: $viewModel.walkthroughStepCompleted,
                                scrollProxy: scrollProxy
                            )
                        }
                    }
                    .ignoresSafeArea()
                }

                // MARK: - Step Completion Detection

                .onChange(of: viewModel.prescription.od.sphere) { _, newValue in
                    withAnimation { viewModel.checkSphereCompletion(newValue) }
                }
                .onChange(of: viewModel.prescription.os.sphere) { _, newValue in
                    withAnimation { viewModel.checkSphereCompletion(newValue) }
                }
                .onChange(of: viewModel.prescription.od.cylinder) { _, newValue in
                    withAnimation { viewModel.checkCylinderCompletion(newValue) }
                }
                .onChange(of: viewModel.prescription.os.cylinder) { _, newValue in
                    withAnimation { viewModel.checkCylinderCompletion(newValue) }
                }
                .onChange(of: viewModel.prescription.od.axis) { old, new in
                    withAnimation { viewModel.checkAxisCompletion(old: old, new: new) }
                }
                .onChange(of: viewModel.prescription.os.axis) { old, new in
                    withAnimation { viewModel.checkAxisCompletion(old: old, new: new) }
                }
                .onChange(of: viewModel.prescription.pd) { _, newValue in
                    withAnimation { viewModel.checkPDCompletion(newValue) }
                }

                // Walkthrough lifecycle
                .onChange(of: viewModel.isWalkthroughActive) { _, active in
                    if !active {
                        viewModel.completeWalkthrough()
                    }
                }
                .onAppear {
                    if !viewModel.hasCompletedWalkthrough {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                scrollProxy.scrollTo("sph", anchor: .center)
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                withAnimation {
                                    viewModel.activateWalkthrough()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
