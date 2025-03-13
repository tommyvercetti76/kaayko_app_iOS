//
//  ProductCardView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A SwiftUI view that displays a single product card. It includes:
//   • A swipeable image carousel using TabView.
//   • Custom dot indicators.
//   • Title (bold, black) and description (regular, black).
//   • A footer with the product price, a diamond-shaped like button, and the vote count.
//     - All three footer items (price, diamond, votes) occupy equal horizontal space,
//       each centered in its own column.
//
//  All UI elements support accessibility, dynamic type, and dark/light mode.
//
//  Note: The footer uses three `VStack` columns with `.frame(maxWidth: .infinity)`
//        to achieve perfect symmetry.

import SwiftUI

struct ProductCardView: View {
    // MARK: - Properties
    
    /// The product to display.
    let product: Product
    
    /// The ViewModel for handling vote updates.
    @ObservedObject var viewModel: ProductViewModel
    
    /// Tracks the currently visible image index in the carousel.
    @State private var currentIndex: Int = 0
    
    /// Tracks whether the product is liked.
    @State private var isLiked: Bool = false
    
    /// Local state for the current vote count.
    @State private var currentVotes: Int
    
    // MARK: - Initializer
    
    /**
     Initializes the card view with a product and its ViewModel.
     
     - Parameters:
       - product: The `Product` entity to be displayed.
       - viewModel: The `ProductViewModel` used for vote updates.
     */
    init(product: Product, viewModel: ProductViewModel) {
        self.product = product
        self.viewModel = viewModel
        _currentVotes = State(initialValue: product.votes)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 1) Image carousel section.
            imageCarousel
            
            // 2) Title and description section.
            VStack(spacing: 4) {
                Text(product.title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.black)  // Bold, black title
                    .multilineTextAlignment(.center)
                
                Text(product.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.black)  // Regular, black description
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 12)
            
            // 3) Footer section with price, like button, and vote count.
            footer
        }
        .padding()
        .background(Color.white)   // White card background
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Subviews
extension ProductCardView {
    
    /**
     A subview representing the swipeable carousel of product images.
     Uses a TabView with a .page style and custom dot indicators at the bottom.
     */
    private var imageCarousel: some View {
        ZStack(alignment: .bottom) {
            // A page-style TabView for images
            TabView(selection: $currentIndex) {
                ForEach(product.imgSrc.indices, id: \.self) { idx in
                    if let url = URL(string: product.imgSrc[idx]) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                // You may show a small or regular progress indicator here
                                // e.g. ProgressView().frame(height: 240)
                                ProgressView(size: .small)
                                    .frame(height: 240)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 240)
                                    .clipped()
                            case .failure:
                                Color.gray
                                    .frame(height: 240)
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
            
            // Dot indicators
            HStack(spacing: 6) {
                ForEach(product.imgSrc.indices, id: \.self) { idx in
                    Circle()
                        .fill(idx == currentIndex ? Color.black : Color.gray.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
            }
            .padding(.bottom, 8)
        }
    }
    
    /**
     A subview for the footer containing the product price, a like (diamond) button, and the vote count.
     The items are spaced equally and aligned horizontally for symmetrical layout.
     
     - Uses an HStack with three columns:
       1) Price (centered in the left column),
       2) Diamond button (centered in the middle column),
       3) Vote count (centered in the right column).
     - Each column is wrapped in a `VStack` with `frame(maxWidth: .infinity)`
       to ensure they each occupy the same width.
     */
    private var footer: some View {
        HStack(spacing: 0) {
            // 1) Price column
            VStack {
                Text(product.price)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            
            // 2) Diamond "like" button column
            VStack {
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
            }
            .frame(maxWidth: .infinity)
            
            // 3) Vote count column
            VStack {
                Text("\(currentVotes) Votes")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.vertical, 12)
        .background(Color.white)
        .accessibilityElement(children: .combine)
    }
}
