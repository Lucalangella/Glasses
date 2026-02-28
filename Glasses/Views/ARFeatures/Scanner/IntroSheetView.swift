//
//  IntroSheetView.swift
//  Glasses
//
//  Created by Luca Langella 1 on 2/26/26.
//

import SwiftUI

struct IntroSheetView: View {
    var onStart: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Advisor")
                .font(.subheadline.weight(.semibold))
                
            
            Text("For best results")
                .font(.title2.weight(.bold))
                .foregroundColor(.black)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("1. Hold the device at arms length")
                Text("2. Follow the indicator on screen")
                Text("3. Face the camera straight on")
            }
            .font(.subheadline)
            .foregroundColor(.black.opacity(0.8))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            
            Button(action: onStart) {
                Text("Got it")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
        }
        .padding(.top, 32)
        .background(Color.white)
        .cornerRadius(32, corners: [.topLeft, .topRight])
    }
}

