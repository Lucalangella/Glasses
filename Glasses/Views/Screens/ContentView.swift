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
    
    // MARK: - Walkthrough Steps (6 refined steps)
    
    private let walkthroughSteps: [WalkthroughStep] = [
        WalkthroughStep(
            id: "prescription",
            title: "Sphere (SPH)",
            body: "Tap SPH to open the ruler, then drag to set a value. Minus (−) means nearsighted, plus (+) means farsighted. This is the main power of your lens.",
            icon: "doc.text.fill",
            accentColor: .blue,
            task: "Try it: tap SPH and drag the ruler to set a value",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "prescription",
            title: "Cylinder (CYL)",
            body: "CYL corrects astigmatism — an irregular curve in your cornea. If your prescription card shows 0.00 for CYL, you don't have astigmatism. Otherwise, tap CYL and set your value.",
            icon: "eye.fill",
            accentColor: .indigo,
            task: "Try it: tap CYL and drag the ruler to set a value",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "prescription",
            title: "Cylinder Axis",
            body: "The axis (0°–180°) tells the lab exactly where to orient your cylinder correction. Tap AXIS to open the ruler and drag to match the number on your prescription card.",
            icon: "dial.low.fill",
            accentColor: .purple,
            task: "Try it: tap AXIS and drag the ruler to set a value",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "tabo",
            title: "Pupillary Distance",
            body: "PD is the distance between the centers of your pupils, in millimeters. It ensures your lenses are perfectly aligned. Type it in manually or tap the face icon to measure with AR.",
            icon: "faceid",
            accentColor: .pink,
            task: "Try it: enter a PD value or measure with AR",
            requiresCompletion: true
        ),
        WalkthroughStep(
            id: "lens",
            title: "Lens Thickness",
            body: "This shows how your prescription affects lens thickness. A higher index (1.67, 1.74) makes lenses thinner and lighter. Try switching between the segments to compare.",
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
                    .padding(.bottom, isWalkthroughActive ? 300 : 0)
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
                    .ignoresSafeArea()
                }
                
                // MARK: - Step Completion Detection
                
                // Step 0: Sphere — detect sphere change
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
                
                // Step 1: Cylinder — detect cylinder change
                .onChange(of: viewModel.prescription.od.cylinder) { _, newValue in
                    if isWalkthroughActive && walkthroughStep == 1 {
                        let val = Double(newValue.replacingOccurrences(of: "+", with: "")) ?? 0
                        if abs(val) >= 0.25 {
                            withAnimation { walkthroughStepCompleted = true }
                        }
                    }
                }
                .onChange(of: viewModel.prescription.os.cylinder) { _, newValue in
                    if isWalkthroughActive && walkthroughStep == 1 {
                        let val = Double(newValue.replacingOccurrences(of: "+", with: "")) ?? 0
                        if abs(val) >= 0.25 {
                            withAnimation { walkthroughStepCompleted = true }
                        }
                    }
                }
                
                // Step 2: Axis — detect axis change via ruler
                .onChange(of: viewModel.prescription.od.axis) { old, new in
                    if isWalkthroughActive && walkthroughStep == 2 && old != new {
                        withAnimation { walkthroughStepCompleted = true }
                    }
                }
                .onChange(of: viewModel.prescription.os.axis) { old, new in
                    if isWalkthroughActive && walkthroughStep == 2 && old != new {
                        withAnimation { walkthroughStepCompleted = true }
                    }
                }
                
                // Step 3: PD — detect PD typed or set via AR scanner
                .onChange(of: viewModel.prescription.pd) { _, newValue in
                    if isWalkthroughActive && walkthroughStep == 3 {
                        if let pdVal = Double(newValue), pdVal > 0 {
                            withAnimation { walkthroughStepCompleted = true }
                        }
                    }
                }
                
                // Step 4: Lens — notification from LensVisualizationView
                .onReceive(NotificationCenter.default.publisher(for: .lensIndexChanged)) { _ in
                    if isWalkthroughActive && walkthroughStep == 4 {
                        withAnimation { walkthroughStepCompleted = true }
                    }
                }
                
                // Step 5: Frames — no completion required
                
                // Auto-start on first launch
                .onAppear {
                    if !hasCompletedWalkthrough {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation {
                                isWalkthroughActive = true
                            }
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

extension Notification.Name {
    static let lensIndexChanged = Notification.Name("lensIndexChanged")
}

#Preview {
    ContentView()
}
