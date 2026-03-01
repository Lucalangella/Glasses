//
//  ResultSheetView.swift
//  Glasses
//
//  Created by Luca Langella 1 on 2/26/26.
//

import SwiftUI

struct ResultsSheetView: View {
    var results: FaceScanResults
    var onContinue: () -> Void
    var onRescan: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Advisor")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.black)
                
            Text("Your measurement")
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
            
            VStack(spacing: 16) {
                // Just the PD Row now, front and center!
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "eye")
                            .foregroundColor(.blue)
                            .frame(width: 30)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Pupillary Distance (PD)")
                                .font(.subheadline)
                              
                            
                            Text(String(format: "%.1f mm", results.pd))
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.black)
                        }
                        Spacer()
                    }
                    
                    Text("This is the distance between your pupils. While this AR scan provides a close estimate, always rely on an optometrist for your official prescription.")
                        .font(.caption)
                        .padding(.leading, 38)
                        .padding(.top, 8)
                }
                .foregroundColor(.black.opacity(0.8))
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                // Added a nice soft shadow since it's the hero element now
                .shadow(color: Color.black.opacity(0.05), radius: 10, x: 0, y: 5)
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.1), lineWidth: 1))
            }
            .padding(.horizontal, 24)
            
            VStack(spacing: 16) {
                Button(action: onContinue) {
                    Text("Apply to Prescription")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(30)
                }
                
                Button(action: onRescan) {
                    Text("Scan Again")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.black.opacity(0.8))
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .background(Color.white)
        .padding(.top, 32)
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        // Background color to help visualize the sheet's top corners
        Color.gray.opacity(0.2).ignoresSafeArea()
        
        ResultsSheetView(
            results: FaceScanResults(pd: 62.5),
            onContinue: {
                print("Apply to Prescription tapped")
            },
            onRescan: {
                print("Scan Again tapped")
            }
        )
  
    }
}
