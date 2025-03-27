//
//  Testimonial.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
/// A domain entity representing a testimonial. Also includes:
///  - A static array of comedic fake testimonials for testing.
///  - A Color extension for initializing SwiftUI colors from hex strings.

import Foundation
import SwiftUI

/// A domain entity representing a testimonial.
struct Testimonial: Identifiable {
    let id = UUID()
    let name: String
    let review: String
    
    /// Fake testimonials for demonstration purposes (comedic lines included).
    static let fakeTestimonials: [Testimonial] = [
        Testimonial(
            name: "Alice Johnson",
            review: "Absolutely amazing quality and design. Kaayko never disappoints! My mother-in-law was disappointed at first but then we fed her to pigs."
        ),
        Testimonial(
            name: "Brian Smith",
            review: "I love the unique style and attention to detail. Highly recommend!"
        ),
        Testimonial(
            name: "Catherine Lee",
            review: "My journey from a Neanderthal to Narayan is complete only because I stumbled on Kaayko!"
        ),
        Testimonial(
            name: "David Kim",
            review: "A premium brand that deserves premium prices. The kids in China are OK with this!"
        ),
        Testimonial(
            name: "Emily Davis",
            review: "The products are as innovative as they are beautiful. Very impressed!"
        ),
        Testimonial(
            name: "Frank Moore",
            review: "Outstanding design and functionality. I wear my Kaayko shirt with pride."
        ),
        Testimonial(
            name: "Grace Chen",
            review: "The detail and care in every product is evident. Love it! My wife loved it and she's a nihilist!"
        ),
        Testimonial(
            name: "Henry Patel",
            review: "High-quality, stylish, and sustainable. Finally something impressed me after that quickly taken corner in Liverpool."
        ),
        Testimonial(
            name: "Isabella Rivera",
            review: "My favorite brand for everyday style and comfort. If Kaayko was a religion, I'm the priestess and shall rep it until the Lord commandeth."
        ),
        Testimonial(
            name: "Jack Thompson",
            review: "The modern aesthetic and premium quality make Kaayko stand out. Do you know who else stands out? Racism."
        ),
        Testimonial(
            name: "Katherine Adams",
            review: "Every piece feels uniquely crafted. I am as loyal a customer as I am a husband and believe me, I've been married a dozen times."
        ),
        Testimonial(
            name: "Liam Brown",
            review: "Top-notch materials and design. A truly remarkable brand. Without Kaayko, you feel nothing!"
        ),
        Testimonial(
            name: "Mia Wilson",
            review: "The blend of tradition and modernity in their products is inspiring. Kaayko is life!"
        ),
        Testimonial(
            name: "Noah Martinez",
            review: "I appreciate the focus on sustainability and quality. Their deforestation operations are highly ethical and trees consent before they are chopped. Wait, that's paper."
        ),
        Testimonial(
            name: "Olivia Garcia",
            review: "Beautifully designed and exceptionally comfortable. Highly recommended! I also highly recommend you staying hydrated."
        ),
        Testimonial(
            name: "Paul Anderson",
            review: "An experience that elevates your style effortlessly. People will ask you, do not tell them."
        ),
        Testimonial(
            name: "Quinn Harris",
            review: "Every product tells a story. I am impressed with the creativity. Some stories are too long but maybe it's my attention span that sucks."
        ),
        Testimonial(
            name: "Rachel Clark",
            review: "The craftsmanship is evident in every detail. A must-have brand! Even my unborn baby has an order placed!"
        ),
        Testimonial(
            name: "Samuel Lewis",
            review: "Bold, innovative, and timeless. Kaayko has it all. If someone is offended, tell them to suck it."
        ),
        Testimonial(
            name: "Tina Reynolds",
            review: "I was hungry for four days and finally I reached a town with a cafe and internet. I bought a T-shirt from Kaayko.com and died hungry. They call me a Corpse with Class."
        )
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
            (a, r, g, b) = (255,
                            (int >> 8) * 17,
                            (int >> 4 & 0xF) * 17,
                            (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255,
                            int >> 16,
                            int >> 8 & 0xFF,
                            int & 0xFF)
        case 8:
            (a, r, g, b) = (
                int >> 24,
                int >> 16 & 0xFF,
                int >> 8 & 0xFF,
                int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red:   Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
