//
//  ContentView.swift
//  Glasses
//

import SwiftUI
import Combine
import ARKit

struct ContentView: View {
    @StateObject private var viewModel = OptometryViewModel()
    @State private var isShowingScanner = false
    
    // MARK: - Walkthrough State
    @AppStorage("hasCompletedWalkthrough") private var hasCompletedWalkthrough = false
    @State private var isWalkthroughActive = false
    @State private var walkthroughStep = 0
    @State private var walkthroughStepCompleted = false
    
    // Snapshot of initial values so we can detect when the user actually changes something
    @State private var initialSphere: String = ""
    @State private var initialAxis: String = ""
    @State private var initialLensIndex: Bool = false // toggled by LensVisualizationView interaction
    
    // MARK: - Walkthrough Steps
    
    private let walkthroughSteps: [WalkthroughStep] = [
        WalkthroughStep(
            id: "prescription",
            title: "Your Prescription",
            body: "Tap SPH to open the ruler, then drag it to set a value. Minus (−) means nearsighted, plus (+) means farsighted. CYL corrects astigmatism and AXIS sets its angle.",
            icon: "doc.text.fill",
            accentColor: .blue,
            task: "Try it: tap SPH and drag the ruler to set a value",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "tabo",
            title: "Axis & PD",
            body: "Drag the protractor needle to set your cylinder axis visually. PD is the distance between your pupils — tap the face icon to measure it with AR.",
            icon: "dial.low.fill",
            accentColor: .purple,
            task: "Try it: drag a protractor needle to change the axis",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "lens",
            title: "Lens Thickness",
            body: "This shows how your prescription affects lens thickness. A higher index (1.67, 1.74) makes lenses thinner. Try switching between the segments to compare.",
            icon: "cube.transparent.fill",
            accentColor: .cyan,
            task: "Try it: tap a different lens index to see the change",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "frames",
            title: "Frame Recommendations",
            body: "Clarity filters frames based on optical rules from your prescription and PD. Tap any frame to see it in 3D or try it on your face with AR.",
            icon: "eyeglasses",
            accentColor: .orange,
            task: nil,
            requiresCompletion: false
        )
    ]

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
                        .id("prescription")
                        .walkthroughAnchor("prescription")
                        
                        // MARK: - Axis & PD
                        TaboMeasurementView(
                            odAxis: $viewModel.prescription.od.axis,
                            osAxis: $viewModel.prescription.os.axis,
                            pdValue: $viewModel.prescription.pd,
                            isShowingScanner: $isShowingScanner
                        )
                        .id("tabo")
                        .walkthroughAnchor("tabo")
                        
                        // MARK: - Lens Thickness Visualization
                        LensVisualizationView(prescription: $viewModel.prescription)
                            .id("lens")
                            .walkthroughAnchor("lens")
                        
                        // MARK: - Frame Recommendations
                        FramesGridView(
                            recommendedFrames: viewModel.recommendedFrames,
                            recommendationReasons: viewModel.recommendationReasons
                        )
                        .id("frames")
                        .walkthroughAnchor("frames")
                    }
                    .padding(.vertical)
                    // Extra bottom padding so the last section can scroll above the card
                    .padding(.bottom, isWalkthroughActive ? 260 : 0)
                }
                .scrollDisabled(isWalkthroughActive)
                .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
                .navigationTitle("Clarity")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            walkthroughStep = 0
                            walkthroughStepCompleted = false
                            withAnimation {
                                isWalkthroughActive = true
                            }
                            withAnimation {
                                scrollProxy.scrollTo("prescription", anchor: .center)
                            }
                        }) {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.accentColor)
                        }
                        .disabled(isWalkthroughActive)
                    }
                }
                .navigationDestination(for: String.self) { frameName in
                    Glasses3DView(frameName: frameName)
                }
                .onTapGesture {
                    if !isWalkthroughActive {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    }
                }
                .fullScreenCover(isPresented: $isShowingScanner) {
                    FaceScannerView(
                        isPresented: $isShowingScanner,
                        finalPD: $viewModel.prescription.pd
                    )
                }
                
                // MARK: - Walkthrough Overlay
                .overlayPreferenceValue(WalkthroughAnchorKey.self) { anchors in
                    GeometryReader { geo in
                        if isWalkthroughActive {
                            WalkthroughOverlay(
                                steps: walkthroughSteps,
                                anchors: anchors,
                                proxy: geo,
                                currentStepIndex: $walkthroughStep,
                                isActive: $isWalkthroughActive,
                                stepCompleted: $walkthroughStepCompleted,
                                scrollProxy: scrollProxy
                            )
                        }
                    }
                }
                
                // MARK: - Step Completion Detection
                
                // Step 0: Prescription — detect sphere change
                .onChange(of: viewModel.prescription.od.sphere) { _, newValue in
                    if isWalkthroughActive && walkthroughStep == 0 {
                        let val = Double(newValue.replacingOccurrences(of: "+", with: "")) ?? 0
                        if abs(val) >= 0.25 {
                            withAnimation { walkthroughStepCompleted = true }
                        }
                    }
                }
                .onChange(of: viewModel.prescription.os.sphere) { _, newValue in
                    if isWalkthroughActive && walkthroughStep == 0 {
                        let val = Double(newValue.replacingOccurrences(of: "+", with: "")) ?? 0
                        if abs(val) >= 0.25 {
                            withAnimation { walkthroughStepCompleted = true }
                        }
                    }
                }
                .onChange(of: viewModel.prescription.od.cylinder) { _, newValue in
                    if isWalkthroughActive && walkthroughStep == 0 {
                        let val = Double(newValue.replacingOccurrences(of: "+", with: "")) ?? 0
                        if abs(val) >= 0.25 {
                            withAnimation { walkthroughStepCompleted = true }
                        }
                    }
                }
                
                // Step 1: Tabo — detect axis change
                .onChange(of: viewModel.prescription.od.axis) { old, new in
                    if isWalkthroughActive && walkthroughStep == 1 && old != new {
                        withAnimation { walkthroughStepCompleted = true }
                    }
                }
                .onChange(of: viewModel.prescription.os.axis) { old, new in
                    if isWalkthroughActive && walkthroughStep == 1 && old != new {
                        withAnimation { walkthroughStepCompleted = true }
                    }
                }
                
                // Step 2: Lens — we use a notification since the picker is inside LensVisualizationView
                .onReceive(NotificationCenter.default.publisher(for: .lensIndexChanged)) { _ in
                    if isWalkthroughActive && walkthroughStep == 2 {
                        withAnimation { walkthroughStepCompleted = true }
                    }
                }
                
                // Auto-start on first launch
                .onAppear {
                    if !hasCompletedWalkthrough {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation {
                                isWalkthroughActive = true
                            }
                            // Scroll first step into view
                            withAnimation(.easeInOut(duration: 0.4)) {
                                scrollProxy.scrollTo("prescription", anchor: .center)
                            }
                        }
                    }
                }
                .onChange(of: isWalkthroughActive) { _, active in
                    if !active {
                        hasCompletedWalkthrough = true
                    }
                }
            }
        }
    }
}

// MARK: - Notification for Lens Index Change
// This lets the LensVisualizationView signal that the user tapped a segment,
// without needing to refactor the entire view's state.

extension Notification.Name {
    static let lensIndexChanged = Notification.Name("lensIndexChanged")
}

#Preview {
    ContentView()
}
