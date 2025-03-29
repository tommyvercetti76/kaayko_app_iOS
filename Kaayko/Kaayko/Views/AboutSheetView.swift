import SwiftUI

struct AboutSheetView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Our Vision & Mission")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text("""
                        At Kaayko, we strive to bring timeless quality and modern design into every product we create. Our mission is to empower individuality through sustainable craftsmanship and innovative style. We believe that true self‐expression comes from wearing products that not only look great but are built to last.
                        """)
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity)
            }
            .navigationTitle("About Kaayko")
            .navigationBarTitleDisplayMode(.inline)
        }
        // Same partial sheet styling
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(20)
    }
}
