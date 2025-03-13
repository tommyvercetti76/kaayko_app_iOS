//
//  ProductCategoryHeaderView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.

//  A horizontally scrollable, sticky header that displays category tags.
//  Tapping a tag filters the product list with a smooth fade transition.
//  Accessibility labels are provided for screen readers.

import SwiftUI

struct ProductCategoryHeaderView: View {
    /// Array of tags (categories) available.
    let tags: [String]
    /// The currently selected tag.
    let selectedTag: String
    /// The ViewModel responsible for updating the filter.
    @ObservedObject var viewModel: ProductViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(tags, id: \.self) { tag in
                    Button(action: {
                        Task {
                            await viewModel.filterProducts(by: tag)
                        }
                    }) {
                        Text(tag)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTag == tag ? Color(.systemOrange) : .primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                    }
                    .buttonStyle(PlainButtonStyle())
                    // Underline the active tag.
                    .overlay(
                        selectedTag == tag ?
                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(Color(.systemOrange))
                            .offset(y: 10)
                        : nil
                    )
                }
            }
            .padding(.horizontal, 16)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Category filter. Selected: \(selectedTag)")
    }
}
