//
//  ProductCardView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A SwiftUI view that displays:
//   1) An image carousel + custom indicators
//   2) Title & description
//   3) A footer with price, votes, and a purely symbolic "cart" icon button
//      - The icon is black when the buy panel is closed, and gold when open.
//      - There is no background around the icon, so it appears as a standalone symbol
//        that changes color. A glow is optionally added when gold.
//   4) A buy panel that slides up from the bottom if `showBuyPanel == true`.
//      - Its sub-elements appear in ascending order, disappear in reverse.
//

import SwiftUI

struct ProductCardView: View {
    
    // MARK: - External Dependencies
    let product: Product
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var kartViewModel: KartViewModel
    
    /// Called whenever the cart updates (e.g., after tapping "DONE").
    var onCartUpdate: () -> Void
    
    // MARK: - States
    
    /// Whether the buy panel is visible
    @State private var showBuyPanel: Bool = false
    
    /// Whether the buy panel should begin its reverse subview animation to close
    @State private var buyPanelShouldClose: Bool = false
    
    /// The current carousel index
    @State private var currentIndex: Int = 0
    
    /// Like/vote state
    @State private var isLiked: Bool = false
    @State private var currentVotes: Int
    
    /// User’s color/size/quantity selections
    @State private var selectedColor: String?
    @State private var selectedSize: String?
    @State private var buyQuantity: Int = 1
    
    // MARK: - Initializer
    
    init(
        product: Product,
        viewModel: ProductViewModel,
        kartViewModel: KartViewModel,
        onCartUpdate: @escaping () -> Void
    ) {
        self.product = product
        self.viewModel = viewModel
        self.kartViewModel = kartViewModel
        self.onCartUpdate = onCartUpdate
        
        _currentVotes = State(initialValue: product.votes)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            
            // 1) Carousel
            imageCarousel
            
            // 2) Dot Indicators
            carouselIndicators
            
            // 3) Title & Description
            VStack(spacing: 4) {
                Text(product.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                
                Text(product.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 12)
            
            // 4) Footer with Price, Votes, Cart Icon
            footer
            
            // 5) If the buy panel is showing, present it with a .move from bottom
            if showBuyPanel {
                BuyPanelView(
                    product: product,
                    kartViewModel: kartViewModel,
                    onCartUpdate: handleDoneInBuyPanel,
                    
                    // Re-tapped cart → close in reverse
                    shouldClose: $buyPanelShouldClose,
                    onClosed: {
                        // Once reversed animations are done, remove panel
                        withAnimation {
                            showBuyPanel = false
                        }
                        buyPanelShouldClose = false
                    },
                    
                    // Selections
                    selectedColor: $selectedColor,
                    selectedSize:  $selectedSize,
                    quantity:      $buyQuantity
                )
                .transition(.move(edge: .bottom))
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
        // Overall open/close for the entire panel
        .animation(.easeInOut(duration: 0.25), value: showBuyPanel)
        .onAppear {
            autoSelectIfSingleOption()
        }
    }
}

// MARK: - Subviews
extension ProductCardView {
    
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
                    Color.gray.frame(height: 240).tag(idx)
                }
            }
        }
        .frame(height: 240)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
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
     Footer with price, diamond votes, and a "cart" button that has **no background**,
     changing from black to gold.
    */
    private var footer: some View {
        HStack(spacing: 0) {
            // Price
            VStack {
                Text(product.price)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            
            // Diamond + votes
            VStack(spacing: 4) {
                Button {
                    Task {
                        isLiked.toggle()
                        let voteChange = isLiked ? 1 : -1
                        await viewModel.updateVotes(for: product, voteChange: voteChange)
                        currentVotes += voteChange
                    }
                } label: {
                    DiamondShape()
                        .fill(isLiked ? Color.red : Color.gray.opacity(0.5))
                        .frame(width: 28, height: 28)
                }
                .accessibilityLabel(isLiked ? "Unlike" : "Like")
                
                Text("\(currentVotes) Votes")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // CART Button: just the icon, no background, color toggles black <-> gold
            VStack {
                Button(action: onBuyButtonTapped) {
                    Image(systemName: "cart.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                        // The icon color is black if panel is closed, gold if open
                        .foregroundColor(showBuyPanel ? .yellow : .black)
                        // If you'd like an extra glow around gold:
                        .shadow(
                            color: showBuyPanel ? Color.yellow.opacity(0.8) : .clear,
                            radius: showBuyPanel ? 12 : 0
                        )
                        // Animate color & glow changes
                        .animation(.easeInOut(duration: 0.3), value: showBuyPanel)
                }
                .frame(width: 44, height: 44) // a tap target
                .accessibilityLabel(showBuyPanel ? "Close the Buy Panel" : "Buy this product")
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }
}

// MARK: - Private Helpers
extension ProductCardView {
    
    private func onBuyButtonTapped() {
        if !showBuyPanel {
            // Open
            withAnimation {
                showBuyPanel = true
            }
        } else {
            // Already open -> request reverse subview animations
            buyPanelShouldClose = true
        }
    }
    
    private func handleDoneInBuyPanel() {
        onCartUpdate()
    }
    
    private func autoSelectIfSingleOption() {
        if product.availableColors.count == 1, selectedColor == nil {
            selectedColor = product.availableColors.first
        }
        if product.availableSizes.count == 1, selectedSize == nil {
            selectedSize = product.availableSizes.first
        }
    }
}
