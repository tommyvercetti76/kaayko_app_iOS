//
//  ProductCardView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
/// A SwiftUI view that displays a single product card. It includes:
///  - A swipeable image carousel using TabView (with custom dot indicators).
///  - Page indicators shown under the carousel but above the product title.
///  - Title (bold, black) and description (regular, black).
///  - A footer with three columns:
///       1) Price (centered),
///       2) A diamond "like" button with vote count underneath,
///       3) A "Buy" button that, when tapped, reveals a custom buy panel below the footer.
///  - The buy panel has a custom circular stepper (+/-) for quantity and a "DONE" button.
///    Tapping "DONE" adds items to the cart via `kartViewModel` and calls `onCartUpdate()`.
///
///  All UI elements preserve the original background colors (white) and do not remove
///  any existing functionality. Dark/light mode remains the same as originally coded
///  (black text, white backgrounds).

import SwiftUI

struct ProductCardView: View {
    // MARK: - Properties
    
    /// The product to display.
    let product: Product
    
    /// The ViewModel for handling vote updates.
    @ObservedObject var viewModel: ProductViewModel
    
    /// The KartViewModel for adding items to the cart.
    @ObservedObject var kartViewModel: KartViewModel
    
    /**
     A closure called whenever the cart is updated (e.g., after user taps "DONE" in the buy panel).
     This allows the parent view to refresh the header or do other updates.
     */
    var onCartUpdate: () -> Void
    
    /// Tracks the currently visible image index in the carousel.
    @State private var currentIndex: Int = 0
    
    /// Tracks whether the product is liked.
    @State private var isLiked: Bool = false
    
    /// Local state for the current vote count.
    @State private var currentVotes: Int
    
    // MARK: - Buy Panel States
    
    /// Whether to show the buy panel below the footer.
    @State private var showBuyPanel: Bool = false
    
    /// The quantity chosen in the buy panel's stepper.
    @State private var buyQuantity: Int = 1
    
    // MARK: - Initializer
    
    /**
     Initializes the card view with a product, product ViewModel, and a cart ViewModel.

     - Parameters:
       - product: The `Product` entity to be displayed.
       - viewModel: The `ProductViewModel` used for vote updates.
       - kartViewModel: The `KartViewModel` used for adding to cart.
       - onCartUpdate: A closure called when the cart changes (e.g., to update the header).
     */
    init(product: Product,
         viewModel: ProductViewModel,
         kartViewModel: KartViewModel,
         onCartUpdate: @escaping () -> Void)
    {
        self.product = product
        self.viewModel = viewModel
        self.kartViewModel = kartViewModel
        self.onCartUpdate = onCartUpdate
        _currentVotes = State(initialValue: product.votes)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1) Image carousel (no overlay for dots).
            imageCarousel
            
            // 2) Page indicators below the image, above the product title.
            carouselIndicators
            
            // 3) Title & description.
            VStack(spacing: 4) {
                Text(product.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black) // Original black
                    .multilineTextAlignment(.center)
                
                Text(product.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 12)
            
            // 4) Footer: Price, Diamond & Votes, Buy Button
            footer
            
            // 5) If showBuyPanel is true, show the buy subview below the footer.
            if showBuyPanel {
                buyPanel
                    // Slide in from bottom effect
                    .transition(.move(edge: .bottom))
            }
        }
        .padding()
        .background(Color.white)   // White card background
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
        .animation(.easeInOut, value: showBuyPanel)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Subviews
extension ProductCardView {
    
    /**
     A swipeable carousel of product images using a TabView with .page style (no built-in indicators).
     */
    private var imageCarousel: some View {
        TabView(selection: $currentIndex) {
            ForEach(product.imgSrc.indices, id: \.self) { idx in
                if let url = URL(string: product.imgSrc[idx]) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView(size: .small)
                                .frame(height: 240)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(height: 240)
                                .clipped()
                        case .failure:
                            Color.gray.frame(height: 240)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .tag(idx)
                } else {
                    // Fallback if the URL is invalid
                    Color.gray.frame(height: 240).tag(idx)
                }
            }
        }
        .frame(height: 240)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    /**
     Custom dot indicators displayed below the carousel (but above the product title).
     */
    private var carouselIndicators: some View {
        HStack(spacing: 6) {
            ForEach(product.imgSrc.indices, id: \.self) { idx in
                Circle()
                    .fill(idx == currentIndex ? Color.black : Color.gray.opacity(0.4))
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.vertical, 8)
    }
    
    /**
     The footer with 3 columns:
       1) Product price
       2) Diamond "like" button (with votes below it)
       3) Buy button (which toggles a buy panel below)
     */
    private var footer: some View {
        HStack(spacing: 0) {
            
            // 1) Price
            VStack {
                Text(product.price)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            
            // 2) Diamond & votes (stacked vertically)
            VStack(spacing: 4) {
                Button(action: {
                    Task {
                        isLiked.toggle()
                        let voteChange = isLiked ? 1 : -1
                        await viewModel.updateVotes(for: product, voteChange: voteChange)
                        currentVotes += voteChange
                    }
                }) {
                    DiamondShape()
                        .fill(isLiked ? Color.red : Color.gray.opacity(0.5))
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel(isLiked ? "Unlike" : "Like")
                
                // Perfectly under diamond
                Text("\(currentVotes) Votes")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // 3) Buy button
            VStack {
                Button(action: {
                    withAnimation {
                        showBuyPanel.toggle()
                    }
                }) {
                    Image(systemName: "cart.badge.plus")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.white)
                        .padding(12)
                }
                .frame(width: 44, height: 44)
                .background(Color.blue)
                .cornerRadius(8)
                .accessibilityLabel("Buy this product")
            }
            .frame(maxWidth: .infinity)
            
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .accessibilityElement(children: .combine)
    }
    
    /**
     The buy panel that appears below the footer, containing:
       - A custom circular stepper for +/- quantity
       - A "DONE" button to add items to the cart and dismiss
     */
    private var buyPanel: some View {
        VStack(spacing: 12) {
            // Custom stepper row
            HStack(spacing: 16) {
                // Circular minus button
                Button(action: {
                    if buyQuantity > 1 {
                        buyQuantity -= 1
                    }
                }) {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(buyQuantity > 1 ? .white : .gray)
                        .padding(12)
                        .background(buyQuantity > 1 ? Color.blue : Color.gray.opacity(0.5))
                        .clipShape(Circle())
                }
                
                // Quantity label
                Text("\(buyQuantity)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                // Circular plus button
                Button(action: {
                    buyQuantity += 1
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding(.top, 12)
            
            // "DONE" button
            Button("DONE") {
                // Add items to cart
                for _ in 0..<buyQuantity {
                    kartViewModel.addToCart(product: product)
                }
                // Notify parent
                onCartUpdate()
                
                // Reset
                withAnimation {
                    showBuyPanel = false
                    buyQuantity = 1
                }
            }
            .font(.system(size: 16, weight: .bold))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.green.cornerRadius(8))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            
        }
        .background(Color.white)
    }
}
