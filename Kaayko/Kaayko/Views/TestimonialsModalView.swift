//
//  TestimonialsModalView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A SwiftUI view that displays the Testimonials modal overlay.
//  The modal appears as a full‑screen overlay with a dark background.
//  It includes a header with the title “Testimonials” and a close button,
//  and a scrollable list of testimonials. Each testimonial displays an avatar (with a randomized background),
//  the review text, and the reviewer’s name.
//  The view supports accessibility, dynamic type, and both dark/light modes.

import SwiftUI

struct TestimonialsModalView: View {
    /// Binding controlling whether the modal is presented.
    @Binding var isPresented: Bool
    
    /// The testimonials to display.
    let testimonials: [Testimonial]
    
    var body: some View {
        ZStack {
            // Full-screen dark overlay.
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .accessibilityHidden(true)
            
            // Modal container.
            VStack(spacing: 0) {
                // Modal header.
                ModalHeaderView(title: "Testimonials") {
                    withAnimation { isPresented = false }
                }
                
                // Scrollable testimonials list.
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(testimonials) { testimonial in
                            TestimonialView(testimonial: testimonial)
                        }
                    }
                    .padding(20)  // Uniform padding for aesthetic spacing.
                }
                .background(Color.white)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9,
                   height: UIScreen.main.bounds.height * 0.8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 6)
            .transition(.scale)
            .accessibilityElement(children: .contain)
        }
    }
}

struct TestimonialsModalView_Previews: PreviewProvider {
    static var previews: some View {
        let fakeTestimonials = Testimonial.fakeTestimonials
        Group {
            TestimonialsModalView(isPresented: .constant(true), testimonials: fakeTestimonials)
                .preferredColorScheme(.light)
            TestimonialsModalView(isPresented: .constant(true), testimonials: fakeTestimonials)
                .preferredColorScheme(.dark)
        }
    }
}
