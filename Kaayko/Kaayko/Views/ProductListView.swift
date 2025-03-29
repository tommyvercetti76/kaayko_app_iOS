//
//  ProductListView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A vertical scrolling list of product cards with a sticky header that contains:
//    • The brand header (with "KAAYKO", About, Testimonials, and Cart buttons + cart count badge)
//    • A horizontally scrollable category header
//  Also shows a progress indicator when loading.
//  Uses native iOS sheets (.sheet) with partial detents for both About & Testimonials.

import SwiftUI

struct ProductListView: View {
    // MARK: - Properties
    
    /// ViewModel providing product and tag data (assumed real-time or cached).
    @ObservedObject var viewModel: ProductViewModel
    
    /// The KartViewModel providing cart data (for badge + adding items).
    @ObservedObject var kartViewModel: KartViewModel
    
    /// State controlling presentation of the About sheet.
    @State private var showAboutSheet = false
    
    /// State controlling presentation of the Testimonials sheet.
    @State private var showTestimonialsSheet = false
    
    /// State controlling presentation of the Cart modal (using .sheet).
    @State private var isKartModalPresented = false
    
    /// Local property to store the cart item count (optional usage).
    @State private var cartItemCount: Int = 0
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        // Spacer for combined header heights: 48 + 60
                        Color.clear.frame(height: 108)
                        
                        // List of product cards
                        ForEach(viewModel.products) { product in
                            ProductCardView(
                                product: product,
                                viewModel: viewModel,
                                kartViewModel: kartViewModel,
                                onCartUpdate: handleCartUpdate
                            )
                            .frame(width: geometry.size.width - 32)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                
                // Sticky headers overlay
                .overlay(
                    AppHeaderView(
                        onAbout: {
                            withAnimation {
                                showAboutSheet = true
                            }
                        },
                        onTestimonials: {
                            withAnimation {
                                showTestimonialsSheet = true
                            }
                        },
                        onCart: {
                            withAnimation {
                                isKartModalPresented = true
                            }
                        },
                        cartCount: kartViewModel.totalItemCount,
                        tags: viewModel.tags,
                        selectedTag: viewModel.selectedTag,
                        onTagSelected: { tag in
                            Task {
                                await viewModel.filterProducts(by: tag)
                            }
                        }
                    ),
                    alignment: .top
                )
            }
            
            // Show a loading indicator if needed
            if viewModel.isLoading {
                ProgressView(size: .regular)
            }
        }
        // Real-time or initial load call
        .onAppear {
            // If using real-time approach:
            viewModel.start()
            
            // If you prefer your old approach:
            // Task { await viewModel.loadInitialData() }
        }
        
        // Cart -> sheet
        .sheet(isPresented: $isKartModalPresented) {
            KartSheetView(kartViewModel: kartViewModel)
        }
        
        // About -> partial-detent sheet
        .sheet(isPresented: $showAboutSheet) {
            AboutSheetView()
        }
        
        // Testimonials -> partial-detent sheet
        .sheet(isPresented: $showTestimonialsSheet) {
            TestimonialsSheetView(testimonials: Testimonial.fakeTestimonials)
        }
    }
    
    // MARK: - Cart Update Handler
    
    /**
     Called whenever a ProductCardView finishes a "DONE" add-to-cart action.
     */
    private func handleCartUpdate() {
        // Re-check cart item count
        cartItemCount = kartViewModel.totalItemCount
        
        // Could also trigger UI changes, analytics, etc.
        print("Cart updated! New total: \(cartItemCount)")
    }
}
