//
//  ProductListView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A vertical scrolling list of product cards with a sticky, horizontally scrollable category header.
//  When products are loading, a custom progress indicator appears over the view.
//  All UI elements support accessibility and adapt to dark/light mode.

import SwiftUI

struct ProductListView: View {
    /// The ViewModel providing product and tag data.
    @ObservedObject var viewModel: ProductViewModel
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 16) {
                        // Spacer equal to header height to avoid overlap with sticky header.
                        Color.clear.frame(height: 60)
                        
                        // Loop through products and display each as a card.
                        ForEach(viewModel.products) { product in
                            ProductCardView(product: product, viewModel: viewModel)
                                .frame(width: geometry.size.width - 32)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("Product: \(product.title), Price: \(product.price), \(product.votes) votes")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
                // Overlay a sticky header for categories at the top.
                .overlay(
                    ProductCategoryHeaderView(tags: viewModel.tags,
                                       selectedTag: viewModel.selectedTag,
                                       viewModel: viewModel)
                        .frame(height: 60)
                        .background(Color(.systemBackground).opacity(0.95))
                        .shadow(radius: 2),
                    alignment: .top
                )
            }
            // Display the custom progress indicator while loading.
            if viewModel.isLoading {
                ProgressView(size: .regular)
            }
        }
        .onAppear {
            Task {
                await viewModel.loadInitialData()
            }
        }
    }
}

