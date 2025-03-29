//
//  ProductListView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A vertical scrolling list of product cards with a sticky header that contains:
//    • The brand header (with "KAAYKO", About, Testimonials, and Cart buttons)
//    • A horizontally scrollable category header
//  Also shows a progress indicator when loading.
//  Now uses native iOS sheets (.sheet) with partial detents for both About & Testimonials.

import SwiftUI

struct ProductListView: View {
    // ViewModel providing product and tag data.
    @ObservedObject var viewModel: ProductViewModel
    
    // The KartViewModel providing cart data.
    @ObservedObject var kartViewModel: KartViewModel
    
    // State controlling presentation of the About sheet.
    @State private var showAboutSheet = false
    
    // State controlling presentation of the Testimonials sheet.
    @State private var showTestimonialsSheet = false
    
    // State controlling presentation of the Cart modal (still using fullScreenCover).
    @State private var isKartModalPresented = false
    
    // Use a local state or computed property to refresh any UI
    @State private var cartItemCount: Int = 0
    
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
                                viewModel: viewModel, kartViewModel: kartViewModel, onCartUpdate: handleCartUpdate
                            )
                            .frame(width: geometry.size.width - 32)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                .overlay(
                    VStack(spacing: 0) {
                        
                        // Sticky brand header
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
                            }
                        )
                        .frame(height: 48)
                        .background(Color(.systemBackground).opacity(0.95))
                        
                        // Sticky category header
                        ProductCategoryHeaderView(
                            tags: viewModel.tags,
                            selectedTag: viewModel.selectedTag,
                            viewModel: viewModel
                        )
                        .frame(height: 60)
                        .background(Color(.systemBackground).opacity(0.95))
                        .shadow(radius: 2)
                    },
                    alignment: .top
                )
            }
            
            // If loading, show progress indicator
            if viewModel.isLoading {
                ProgressView(size: .regular)
            }
        }
        // Load data once on appear
        .onAppear {
            Task {
                await viewModel.loadInitialData()
            }
        }
        
        // Cart -> fullScreenCover
        .sheet(isPresented: $isKartModalPresented) {
            KartSheetView(kartViewModel: kartViewModel)
        }

        
        // About -> new sheet with partial detents
        .sheet(isPresented: $showAboutSheet) {
            AboutSheetView()
        }
        
        // Testimonials -> new sheet with partial detents
        .sheet(isPresented: $showTestimonialsSheet) {
            TestimonialsSheetView(testimonials: Testimonial.fakeTestimonials)
        }
    }
    
    // MARK: - Cart Update Handler
        
        /**
         Called whenever a ProductCardView finishes a "DONE" add-to-cart action.
         */
        private func handleCartUpdate() {
            // Example: re-check cart item count
            cartItemCount = kartViewModel.totalItemCount
            
            // You can also trigger any UI changes here, like
            // updating a badge or calling an analytics event.
            print("Cart updated! New total: \(cartItemCount)")
        }
}
