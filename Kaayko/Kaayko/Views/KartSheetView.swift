import SwiftUI

struct KartSheetView: View {
    @ObservedObject var kartViewModel: KartViewModel
    
    var body: some View {
        NavigationView {
            VStack {
                if kartViewModel.items.isEmpty {
                    // Show empty cart
                    Text("Your cart is empty.")
                        .font(.title2)
                        .padding()
                    Spacer()
                } else {
                    List {
                        ForEach(kartViewModel.items) { item in
                            HStack {
                                Text(item.product.title)
                                Spacer()
                                Text("\(item.quantity)x")
                            }
                        }
                    }
                    .listStyle(.inset)
                    
                    // Subtotal / Checkout
                    VStack(spacing: 8) {
                        Text("Subtotal: $\(kartViewModel.totalPrice, specifier: "%.2f")")
                            .font(.system(size: 18, weight: .medium))
                        Button("Checkout") {
                            // Perform checkout
                        }
                        .font(.system(size: 18, weight: .bold))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                }
            }
            .navigationTitle("Your Cart (\(kartViewModel.totalItemCount))")
            .navigationBarTitleDisplayMode(.inline)
        }
        // iOS 16 partial sheet style
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationBackground(.regularMaterial)
        .presentationCornerRadius(20)
    }
}
