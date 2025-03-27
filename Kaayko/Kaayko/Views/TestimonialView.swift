//
//  TestimonialView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//

import SwiftUI

struct TestimonialView: View {
    /// The testimonial data to display.
    let testimonial: Testimonial
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar with randomized background color.
            Circle()
                .fill(randomAvatarColor())
                .frame(width: 44, height: 44)
                .overlay(
                    Text(String(testimonial.name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )
                .accessibilityHidden(true)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("\"\(testimonial.review)\"")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(.primary)        // Adaptive color
                    .multilineTextAlignment(.leading)
                
                Text(testimonial.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)      // Lighter in dark mode
            }
            .accessibilityElement(children: .combine)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    func randomAvatarColor() -> Color {
        let colors: [Color] = [
            Color(hex: "#ff8c00"), // Professional orange
            Color(hex: "#e63946"), // Red
            Color(hex: "#2a9d8f"), // Teal
            Color(hex: "#264653"), // Dark slate
            Color(hex: "#f4a261"), // Light orange
            Color(hex: "#457b9d"), // Steel blue
            Color(hex: "#8a4fff"), // Purple
            Color(hex: "#00b4d8"), // Cyan
            Color(hex: "#6a994e")  // Greenish
        ]
        return colors.randomElement() ?? Color(hex: "#ff8c00")
    }
}
