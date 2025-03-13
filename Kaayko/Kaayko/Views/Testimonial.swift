//
//  Testimonial.swift
//  Kaayko
//
//  Created by Rohan Ramekar on [Date].
//
//  A domain entity representing a testimonial.
//  Includes fake data for testing and demonstration.

import Foundation
import SwiftUI

/// A domain entity representing a testimonial.
struct Testimonial: Identifiable {
    let id = UUID()
    let name: String
    let review: String
    
    /// Fake testimonials for demonstration purposes.
    static let fakeTestimonials: [Testimonial] = [
        Testimonial(name: "Alice Johnson", review: "Absolutely amazing quality and design. Kaayko never disappoints!"),
        Testimonial(name: "Brian Smith", review: "I love the unique style and attention to detail. Highly recommend!"),
        Testimonial(name: "Catherine Lee", review: "Every piece feels uniquely crafted. A true standout brand."),
        Testimonial(name: "David Kim", review: "A premium experience from start to finish. Truly remarkable!"),
        Testimonial(name: "Emily Davis", review: "Innovative and beautifully designed. Very impressed with Kaayko.")
        // Add more testimonials as needed.
    ]
}

/// An extension to initialize a Color from a hex string.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
