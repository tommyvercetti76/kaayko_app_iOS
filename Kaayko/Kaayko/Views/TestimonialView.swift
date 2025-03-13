//
//  TestimonialView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A SwiftUI view that displays a single testimonial with:
//  - A circular avatar with the reviewer’s initial and a random background color.
//  - The review text and the reviewer’s name.
//  The view supports accessibility and adapts to dark/light mode.

import SwiftUI

struct TestimonialView: View {
    /// The testimonial data to display.
    let testimonial: Testimonial
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar with randomized background color.
            Circle()
                .fill(randomAvatarColor())
                .frame(width: 40, height: 40)
                .overlay(
                    Text(String(testimonial.name.prefix(1)).uppercased())
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                )
                .accessibilityHidden(true)
            
            // Testimonial content.
            VStack(alignment: .leading, spacing: 4) {
                Text("\"\(testimonial.review)\"")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                Text(testimonial.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.gray)
            }
            .accessibilityElement(children: .combine)
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    /**
     Returns a random color for the avatar background.
     
     - Returns: A `Color` chosen at random from a predefined list.
     */
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
