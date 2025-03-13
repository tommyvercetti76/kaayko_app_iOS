//
//  ProductListView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A vertical scrolling list of product cards with a sticky header that contains:
//    • The brand header (with "KAAYKO" and modal buttons)
//    • A horizontally scrollable category header below the brand header.
//  When products are loading, a custom progress indicator appears.
//  All UI elements support accessibility and adapt to dark/light mode.

import SwiftUI

struct ProductListView: View {
    /// The ViewModel providing product and tag data.
    @ObservedObject var viewModel: ProductViewModel
    
    /// Controls presentation of the About modal.
    @State private var isAboutModalPresented = false
    /// Controls presentation of the Testimonials modal.
    @State private var isTestimonialsModalPresented = false
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        // Spacer to account for the combined header heights.
                        Color.clear.frame(height: 108) // 48 (AppHeaderView) + 60 (CategoryHeaderView)
                        
                        // Loop through products and display each as a card.
                        ForEach(viewModel.products) { product in
                            ProductCardView(product: product, viewModel: viewModel)
                                .frame(width: geometry.size.width - 32) // 16 dp margin on each side.
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Product: \(product.title), Price: \(product.price), \(product.votes) votes")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                // Overlay sticky headers: the brand header and category header.
                .overlay(
                    VStack(spacing: 0) {
                        // AppHeaderView: displays brand name and modal buttons.
                        AppHeaderView(onAbout: {
                            withAnimation { isAboutModalPresented = true }
                        }, onTestimonials: {
                            withAnimation { isTestimonialsModalPresented = true }
                        })
                        .frame(height: 48)
                        .background(Color(.systemBackground).opacity(0.95))
                        
                        // CategoryHeaderView: horizontally scrollable category tags.
                        ProductCategoryHeaderView(tags: viewModel.tags,
                                                  selectedTag: viewModel.selectedTag,
                                                  viewModel: viewModel)
                            .frame(height: 60)
                            .background(Color(.systemBackground).opacity(0.95))
                            .shadow(radius: 2)
                    },
                    alignment: .top
                )
            }
            // Display a custom progress indicator when loading.
            if viewModel.isLoading {
                ProgressView(size: .regular)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadInitialData()
            }
        }
        // Full-screen modal presentations.
        .fullScreenCover(isPresented: $isAboutModalPresented) {
            AboutModalView(isPresented: $isAboutModalPresented)
        }
        .fullScreenCover(isPresented: $isTestimonialsModalPresented) {
            TestimonialsModalView(isPresented: $isTestimonialsModalPresented, testimonials: Testimonial.fakeTestimonials)
        }
    }
}
