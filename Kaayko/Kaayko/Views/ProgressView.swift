//
//  ProgressView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A custom, animated progress indicator displayed while product data is loading.
//  Uses a trimmed circle with an angular gradient and a continuous rotation animation.
//  Accessible and supports both light and dark mode.
//


import SwiftUI

/// The available size configurations for the custom progress view.
enum ProgressViewSize {
    /// Small progress view (e.g., within a card or container).
    case small
    /// Regular progress view (e.g., full-screen overlay).
    case regular
}

struct ProgressView: View {
    /// Determines which size configuration to use.
    let size: ProgressViewSize
    
    /// State variable to trigger the rotation animation.
    @State private var isAnimating: Bool = false
    
    /// Computed property for the frame size based on the selected size.
    private var frameSize: CGFloat {
        switch size {
        case .small: return 40
        case .regular: return 80
        }
    }
    
    /// Computed property for the line width of the progress arc.
    private var lineWidth: CGFloat {
        switch size {
        case .small: return 4
        case .regular: return 8
        }
    }
    
    var body: some View {
        Circle()
            // Trim the circle to create an arc
            .trim(from: 0.2, to: 1)
            // Use an angular gradient for a sleek effect
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [Color.orange, Color.red, Color.orange]),
                    center: .center
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: frameSize, height: frameSize)
            // Continuous rotation animation.
            .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
            .onAppear {
                withAnimation(Animation.linear(duration: 1).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
            .accessibilityElement()
            .accessibilityLabel("Loading")
    }
}
