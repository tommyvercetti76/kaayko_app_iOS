import SwiftUI

struct TestimonialsSheetView: View {
    /// The testimonials to display.
    let testimonials: [Testimonial]
    
    var body: some View {
        NavigationView {
            List(testimonials) { testimonial in
                TestimonialView(testimonial: testimonial)
            }
            .navigationTitle("Testimonials")
            .navigationBarTitleDisplayMode(.inline)
        }
        // iOS 16+ partial sheet with a blurred “material” background
        .presentationDetents([.medium, .large])       // let users pick partial or full
        .presentationDragIndicator(.visible)          // show the grab handle
        .presentationBackground(.regularMaterial)     // blurred background for the sheet
        .presentationCornerRadius(20)                 // round the sheet corners a bit
    }
}
