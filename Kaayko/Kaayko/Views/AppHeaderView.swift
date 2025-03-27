//
//  AppHeaderView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A sticky header view that displays:
//   - The brand name ("KAAYKO")
//   - Three circular buttons: About, Testimonials, and Cart
//  Each button calls a closure passed in from above.

import SwiftUI

struct AppHeaderView: View {
    /// Called when the About button is tapped.
    var onAbout: () -> Void
    
    /// Called when the Testimonials button is tapped.
    var onTestimonials: () -> Void
    
    /// Called when the Cart button is tapped.
    var onCart: () -> Void

    var body: some View {
        HStack {
            // Brand name.
            Text("KAAYKO")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .accessibilityLabel("Kaayko Brand")
            
            Spacer()
            
            // About button.
            Button(action: { onAbout() }) {
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "info.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.primary)
                            .padding(4)
                    )
            }
            .accessibilityLabel("About")
            
            Spacer().frame(width: 8)
            
            // Testimonials button.
            Button(action: { onTestimonials() }) {
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "text.bubble")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.primary)
                            .padding(4)
                    )
            }
            .accessibilityLabel("Testimonials")
            
            Spacer().frame(width: 8)
            
            // Cart button.
            Button(action: { onCart() }) {
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "bag")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.primary)
                            .padding(4)
                    )
            }
            .accessibilityLabel("Cart")
        }
        .padding(.horizontal, 16)
    }
}
