//
//  KartView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/16/25.
//
//  A SwiftUI view that displays the user's cart as a full-screen overlay,
//  with a matched-geometry effect from a reference frame (like the cart button).
//  The kart items are displayed in a list, each with quantity controls.

import SwiftUI

/// A full-screen overlay that animates from the cart button using matched geometry.
struct KartView: View {
    /// Binding controlling whether this view is presented.
    @Binding var isPresented: Bool
    
    /// The KartViewModel that stores cart items.
    @ObservedObject var kartViewModel: KartViewModel
    
    /// The same namespace used for matched geometry from the button.
    var namespace: Namespace.ID
    
    /// For controlling the fade-in of cart contents after the geometry expands.
    @State private var showCartContents = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Full-screen background to capture taps.
            // You could also use a background color with partial opacity.
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    // If you want tapping outside to close the cart:
                    withAnimation(.spring()) {
                        isPresented = false
                    }
                }
            
            // The main cart container.
            // Matches geometry with the cart button via "cartButton" ID.
            VStack(spacing: 0) {
                // Placeholder top bar for the cart (like a nav bar).
                HStack {
                    Text("Your Cart (\(kartViewModel.totalItemCount))")
                        .font(.system(size: 20, weight: .bold))
                    Spacer()
                    Button(action: {
                        withAnimation(.spring()) {
                            isPresented = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }
                .padding()
                .background(Color.white)
                
                if showCartContents {
                    // A list of items in the cart.
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(kartViewModel.items) { item in
                                cartItemRow(item: item)
                            }
                        }
                        .padding()
                    }
                    
                    // A bottom summary / checkout bar.
                    VStack {
                        Text("Subtotal: $\(kartViewModel.totalPrice, specifier: "%.2f")")
                            .font(.system(size: 18, weight: .medium))
                        Button("Checkout") {
                            // Perform checkout logic...
                        }
                        .font(.system(size: 18, weight: .bold))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .padding()
                    .background(Color.white)
                }
            }
            .frame(width: UIScreen.main.bounds.width * 0.9,
                   height: UIScreen.main.bounds.height * 0.8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 8)
            // Attach the matched geometry effect to the container.
            .matchedGeometryEffect(id: "cartButton", in: namespace)
        }
        .onAppear {
            // After the geometry expansion completes, fade in cart contents.
            withAnimation(.easeIn.delay(0.2)) {
                showCartContents = true
            }
        }
        .onDisappear {
            // Reset for next time.
            showCartContents = false
        }
    }
    
    /// A single row in the cart showing product info and quantity controls.
    @ViewBuilder
    private func cartItemRow(item: KartItem) -> some View {
        HStack(spacing: 12) {
            // A simple image or placeholder for the product.
            if let firstImage = item.product.imgSrc.first, let url = URL(string: firstImage) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty: ProgressView(size: .small).frame(width: 60, height: 60)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .cornerRadius(8)
                    case .failure: Color.gray.frame(width: 60, height: 60).cornerRadius(8)
                    @unknown default: EmptyView()
                    }
                }
            } else {
                Color.gray.frame(width: 60, height: 60).cornerRadius(8)
            }
            
            // Title and Price
            VStack(alignment: .leading, spacing: 4) {
                Text(item.product.title)
                    .font(.system(size: 16, weight: .bold))
                Text(item.product.price)
                    .font(.system(size: 14, weight: .regular))
            }
            
            Spacer()
            
            // Quantity controls
            HStack {
                Button(action: {
                    kartViewModel.updateQuantity(for: item, delta: -1)
                }) {
                    Image(systemName: "minus.circle")
                }
                Text("\(item.quantity)")
                    .font(.system(size: 16, weight: .medium))
                    .frame(minWidth: 20)
                Button(action: {
                    kartViewModel.updateQuantity(for: item, delta: +1)
                }) {
                    Image(systemName: "plus.circle")
                }
            }
            .font(.system(size: 18))
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(item.product.title), quantity \(item.quantity)")
    }
}
