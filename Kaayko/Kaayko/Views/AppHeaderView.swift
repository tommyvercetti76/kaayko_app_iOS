//
//  AppHeaderView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on [Date].
//
//  A sticky header view that displays the brand name ("KAAYKO")
//  and two circular buttons that trigger the presentation of separate modals:
//  one for About and one for Testimonials. The buttons use custom icons that
//  are larger, and the buttons themselves are displayed with only a circular border,
//  without any filled background color. The view supports accessibility and dark/light mode.

import SwiftUI

/// A header view for the app that displays the brand name and modal buttons.
struct AppHeaderView: View {
    /// Closure invoked when the About button is tapped.
    var onAbout: () -> Void
    /// Closure invoked when the Testimonials button is tapped.
    var onTestimonials: () -> Void

    var body: some View {
        HStack {
            // Brand name, centered.
            Text("KAAYKO")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .accessibilityLabel("Kaayko Brand")
            
            Spacer()
            
            // "About" Button.
            Button(action: {
                onAbout()
            }) {
                // Draw a circle outline without a fill.
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 44, height: 44)
                    .overlay(
                        // Custom About icon scaled up for better visibility.
                        Image("about")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    )
            }
            .accessibilityLabel("About")
            
            Spacer().frame(width: 8)
            
            // "Testimonials" Button.
            Button(action: {
                onTestimonials()
            }) {
                Circle()
                    .stroke(Color.primary, lineWidth: 1)
                    .frame(width: 44, height: 44)
                    .overlay(
                        // Custom Testimonials icon scaled up.
                        Image("testimonials")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 44, height: 44)
                    )
            }
            .accessibilityLabel("Testimonials")
        }
        .padding(.horizontal, 16)
    }
}
