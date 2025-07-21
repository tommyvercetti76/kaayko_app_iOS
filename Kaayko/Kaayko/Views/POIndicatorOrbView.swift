//
//  POIndicatorOrbView.swift
//  Listen To Water
//
//  Created by Rohan Ramekar on 1/20/24.
//

import SwiftUI

struct POIndicatorOrbView: View {
    @Binding var currentPageIndex: Int
    var totalCards: Int

    private var orbColor: Color {
        switch currentPageIndex {
        case totalCards - 1:
            return .red
        case let x where x >= Int(Double(totalCards) * 0.7):
            return .orange
        default:
            return .green
        }
    }

    var body: some View {
        Circle()
            .fill(orbColor)
            .overlay(Circle().stroke(Color.white, lineWidth: 0.24))
            .shadow(radius: 0.12)
            .animation(.easeInOut, value: currentPageIndex)
            .glow(color: orbColor, radius: 4) // Adding glow effect
            .frame(width: 20, height: 20)
            .padding()
    }
}

// Extension to add a glow effect
extension View {
    func glow(color: Color = .white, radius: CGFloat = 10) -> some View {
        self.overlay(self.blur(radius: radius))
            .shadow(color: color, radius: radius)
            .opacity(0.9)
    }
}
