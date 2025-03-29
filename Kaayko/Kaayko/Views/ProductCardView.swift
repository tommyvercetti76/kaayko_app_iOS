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
///  - The buy panel has:
///       - A color selection row (circles for available colors),
///       - A size selection row (S, M, L),
///       - A custom circular stepper (+/-) for quantity (up to 3),
///       - A "DONE" button that adds items to the cart (quantity times) via `kartViewModel`
///         and calls `onCartUpdate()`.
///
///  When the "DONE" button is tapped, the panel closes, quantity resets to 1, and
///  the cart header is updated via `onCartUpdate()`.
///
///  All UI elements preserve the original background colors (white). Dark/light mode is unchanged
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
    
    /// The quantity chosen in the buy panel's stepper (1...3).
    @State private var buyQuantity: Int = 1
    
    /// The currently selected color name. (If nil, user hasn't selected yet.)
    @State private var selectedColor: String? = nil
    
    /// The currently selected size. (If nil, user hasn't selected yet.)
    @State private var selectedSize: String? = nil
    
    // Preset arrays for color & size selection:
    private let availableColors = ["Red", "Blue", "Green"]
    private let availableSizes = ["S", "M", "L"]
    
    // MARK: - Initializer
    
    /**
     Initializes the card view with a product, product ViewModel, and a cart ViewModel.
     - Parameters:
       - product: The `Product` entity to be displayed.
       - viewModel: The `ProductViewModel` used for vote updates.
       - kartViewModel: The `KartViewModel` used for adding to cart.
       - onCartUpdate: A closure called when the cart changes (e.g., to update the header).
     */
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
        
        // Initialize currentVotes with the product's votes
        _currentVotes = State(initialValue: product.votes)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // 1) Image carousel
            imageCarousel
            
            // 2) Page indicators
            carouselIndicators
            
            // 3) Title & description
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
            
            // 4) Footer (Price, Diamond+Votes, Buy)
            footer
            
            // 5) If buy panel is shown, reveal it below the footer
            if showBuyPanel {
                buyPanel
                    .transition(.move(edge: .bottom))
            }
        }
        .padding()
        .background(Color.white) // White card background
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 6, x: 0, y: 2)
        .animation(.easeInOut, value: showBuyPanel)
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Subviews & Private Helpers
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
     Custom dot indicators displayed below the carousel.
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
     The footer with:
       - Price,
       - Diamond + votes,
       - Buy button to open the buy panel.
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
            
            // Diamond + Votes
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
                
                Text("\(currentVotes) Votes")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity)
            
            // Buy button
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
     A revised buy panel that appears below the footer, arranged in a grid-like layout:
       - Left column has labels: "Color," "Size," "Quantity"
       - Right column has the corresponding UI elements (color circles, size buttons, stepper).
       - The "DONE" button appears at the bottom, spanning full width.
       - Stepper has symmetrical +/- buttons, and quantity is limited to [1..3].
       - "DONE" is disabled until user selects both color and size.
    */
    private var buyPanel: some View {
        VStack(spacing: 16) {
            
            // 1) COLOR row (Left=Label, Right=Color Circles)
            HStack {
                // Left label
                Text("Color")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 70, alignment: .leading)  // adjust width to your liking
                
                Spacer()
                
                // Right side: color circles
                HStack(spacing: 12) {
                    ForEach(availableColors, id: \.self) { colorName in
                        Button {
                            selectedColor = colorName
                        } label: {
                            Circle()
                                .fill(colorFromName(colorName))
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color.black, lineWidth: selectedColor == colorName ? 2 : 0)
                                )
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            
            // 2) SIZE row (Left=Label, Right=Size Buttons)
            HStack {
                // Left label
                Text("Size")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 70, alignment: .leading)
                
                Spacer()
                
                // Right side: size buttons
                HStack(spacing: 12) {
                    ForEach(availableSizes, id: \.self) { size in
                        Button {
                            selectedSize = size
                        } label: {
                            Text(size)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(selectedSize == size ? Color.blue : Color.gray)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
            
            // 3) QUANTITY row (Left=Label, Right=Stepper)
            HStack {
                // Left label
                Text("Quantity")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(width: 70, alignment: .leading)
                
                Spacer()
                
                // Right side: symmetrical stepper
                HStack(spacing: 12) {
                    
                    // Minus button (same size as plus)
                    Button(action: {
                        if buyQuantity > 1 {
                            buyQuantity -= 1
                        }
                    }) {
                        Image(systemName: "minus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            // Matching width/height for symmetrical shape
                            .frame(width: 32, height: 32)
                            .background(buyQuantity > 1 ? Color.blue : Color.gray.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .disabled(buyQuantity <= 1)
                    
                    // Quantity label
                    Text("\(buyQuantity)")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.black)
                    
                    // Plus button (same size as minus)
                    Button(action: {
                        if buyQuantity < 3 {
                            buyQuantity += 1
                        }
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            // Matching width/height for symmetrical shape
                            .frame(width: 32, height: 32)
                            .background(buyQuantity < 3 ? Color.blue : Color.gray.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .disabled(buyQuantity >= 3)
                }
            }
            .padding(.horizontal, 16)
            
            // 4) DONE button (full width)
            Button("DONE") {
                print("DEBUG: DONE tapped -> color=\(selectedColor ?? "nil"), size=\(selectedSize ?? "nil"), quantity=\(buyQuantity)")
                
                // Add items to cart
                for _ in 0..<buyQuantity {
                    kartViewModel.addToCart(product: product)
                }
                
                // Notify parent (refresh cart header, etc.)
                onCartUpdate()
                
                // Close panel & reset
                withAnimation {
                    showBuyPanel = false
                    buyQuantity = 1
                    selectedColor = nil
                    selectedSize = nil
                }
            }
            .font(.system(size: 16, weight: .bold))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(Color.green.cornerRadius(8))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.bottom, 12)
            .disabled(selectedColor == nil || selectedSize == nil)
            
        }
        .background(Color.white)
    }
    
    /**
     A horizontal row of color circles (Red, Blue, Green).
     Tapping sets `selectedColor`.
     */
    private var colorSelectionRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose a Color:")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                ForEach(availableColors, id: \.self) { colorName in
                    // A circle representing this color
                    Button(action: {
                        selectedColor = colorName
                    }) {
                        Circle()
                            .fill(colorFromName(colorName))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(Color.black, lineWidth: selectedColor == colorName ? 2 : 0)
                            )
                    }
                }
            }
        }
        .padding(.top, 12)
        .padding(.horizontal, 16)
    }
    
    /**
     A horizontal row for size selection (S, M, L).
     */
    private var sizeSelectionRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Choose a Size:")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
            
            HStack(spacing: 12) {
                ForEach(availableSizes, id: \.self) { size in
                    Button(action: {
                        selectedSize = size
                    }) {
                        Text(size)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                selectedSize == size ? Color.blue : Color.gray
                            )
                            .cornerRadius(8)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
    
    /// A row that lets the user select a quantity from 1 to 3.
    private var stepperRow: some View {
        HStack(spacing: 16) {
            // Minus
            Button(action: {
                if buyQuantity > 1 {
                    buyQuantity -= 1
                }
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(buyQuantity > 1 ? Color.blue : Color.gray.opacity(0.5))
                    .clipShape(Circle())
            }
            .disabled(buyQuantity <= 1)
            
            // Quantity label
            Text("\(buyQuantity)")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.black)
            
            // Plus
            Button(action: {
                if buyQuantity < 3 {
                    buyQuantity += 1
                }
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(buyQuantity < 3 ? Color.blue : Color.gray.opacity(0.5))
                    .clipShape(Circle())
            }
            .disabled(buyQuantity >= 3)
        }
    }

    /// A button that adds items to the cart and closes the panel.
    // Disabled unless both color & size are selected.
    private var doneButton: some View {
        Button("DONE") {
            print("DEBUG: DONE tapped. Adding \(buyQuantity) items to cart. color=\(selectedColor ?? "nil"), size=\(selectedSize ?? "nil")")
            
            // Add items to cart
            for _ in 0..<buyQuantity {
                kartViewModel.addToCart(product: product)
            }
            
            // Notify parent so it can refresh the cart badge
            onCartUpdate()
            
            // Close panel & reset
            withAnimation {
                showBuyPanel = false
                buyQuantity = 1
                selectedColor = nil
                selectedSize = nil
            }
        }
        .font(.system(size: 16, weight: .bold))
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Color.green.cornerRadius(8))
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .disabled(selectedColor == nil || selectedSize == nil)
    }
    
    /**
     Helper to return a SwiftUI Color from a simple color name.
     Expand as needed for more colors.
     */
    private func colorFromName(_ name: String) -> Color {
        switch name {
        case "Red":   return .red
        case "Blue":  return .blue
        case "Green": return .green
        default:      return .gray
        }
    }
}
