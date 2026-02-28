//
//  AboutVIew.swift
//  Glasses
//
//  Created by Luca Langella 1 on 2/28/26.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                
                // MARK: - Header
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.blue.opacity(0.2), .purple.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "eyeglasses")
                            .font(.system(size: 44))
                            .foregroundColor(.accentColor)
                    }
                    
                    Text("Clarity")
                        .font(.largeTitle.weight(.bold))
                    
                    Text("Understand your eyes.")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 24)
                
                // MARK: - Personal Essay
                VStack(alignment: .leading, spacing: 16) {
                    Label("Why I Built This", systemImage: "heart.fill")
                        .font(.headline)
                        .foregroundColor(.pink)
                    
                    Text("I've been wearing glasses since I was nine years old. For years, the prescription card I received after every eye exam was a mystery — a grid of numbers and abbreviations that I simply handed to someone behind a counter.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    Text("It wasn't until recently that an optician took the time to walk me through it all: what SPH and CYL mean, why axis matters, how a strong prescription affects which frames you should choose, and how lens index can make thick lenses thin.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                    
                    Text("That conversation changed how I saw my own glasses — not as a medical necessity I didn't understand, but as something I could make informed choices about. Clarity is my attempt to give that same understanding to everyone who wears glasses.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding(20)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // MARK: - Technologies
                VStack(alignment: .leading, spacing: 16) {
                    Label("Built With", systemImage: "hammer.fill")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    VStack(spacing: 12) {
                        TechRow(
                            framework: "ARKit",
                            icon: "arkit",
                            description: "Face tracking for pupillary distance measurement and virtual try-on"
                        )
                        TechRow(
                            framework: "RealityKit",
                            icon: "cube.fill",
                            description: "3D glasses rendering with physically-based materials"
                        )
                        TechRow(
                            framework: "SceneKit",
                            icon: "rotate.3d",
                            description: "Interactive 3D model preview with camera controls"
                        )
                        TechRow(
                            framework: "SwiftUI",
                            icon: "swift",
                            description: "Entire interface built declaratively with custom controls"
                        )
                    }
                }
                .padding(20)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // MARK: - Features Highlight
                VStack(alignment: .leading, spacing: 16) {
                    Label("What You Can Do", systemImage: "star.fill")
                        .font(.headline)
                        .foregroundColor(.yellow)
                    
                    VStack(spacing: 12) {
                        FeatureRow(icon: "slider.horizontal.3", title: "Enter Your Prescription", description: "Custom ruler and protractor controls make input intuitive")
                        FeatureRow(icon: "faceid", title: "Measure Your PD", description: "AR face scanning calculates your pupillary distance")
                        FeatureRow(icon: "eyeglasses", title: "Get Frame Recommendations", description: "Optical rules filter frames based on your Rx and PD")
                        FeatureRow(icon: "cube.transparent", title: "Visualize Lens Thickness", description: "See how different lens indices affect your lenses")
                        FeatureRow(icon: "face.dashed", title: "Virtual Try-On", description: "See 3D glasses on your face using AR face tracking")
                    }
                }
                .padding(20)
                .background(Color(UIColor.secondarySystemGroupedBackground))
                .cornerRadius(16)
                .padding(.horizontal)
                
                // MARK: - Disclaimer
                VStack(alignment: .leading, spacing: 8) {
                    Label("Important Note", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.orange)
                    
                    Text("Clarity is an educational tool designed to help you understand your prescription. It is not a substitute for professional eye care. Always consult a licensed optometrist or ophthalmologist for your eye health needs.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
                .padding(16)
                .background(Color.orange.opacity(0.08))
                .cornerRadius(12)
                .padding(.horizontal)
                
                // MARK: - Credits
                VStack(spacing: 8) {
                    Text("Made with ❤️ by Luca Langella")
                        .font(.subheadline.weight(.medium))
                    
                    Text("Swift Student Challenge 2026")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button("Replay Introduction") {
                        hasCompletedOnboarding = false
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                    .padding(.top, 8)
                }
                .padding(.vertical, 24)
            }
            .padding(.vertical)
        }
        .background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Supporting Views

struct TechRow: View {
    let framework: String
    let icon: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(framework)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        AboutView()
    }
}
