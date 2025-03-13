//
//  DiamondShape.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A SwiftUI Shape that draws a diamond, used for the like (vote) button.

import SwiftUI

struct DiamondShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        // Draw a diamond by connecting midpoints of each side.
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.closeSubpath()
        return path
    }
}
