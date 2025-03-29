//
//  AppHeaderView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A sticky header view that displays:
//   - The brand name ("KAAYKO")
//   - Three circular buttons: About, Testimonials, and Cart (with cart count badge)
//   - A horizontally scrollable category header below the brand row
//  Each button calls a closure passed in from above.
//  Tapping on a category calls onTagSelected(tag) to filter products.

import SwiftUI

struct AppHeaderView: View {
    
    // MARK: - Brand Header Callbacks
    /// Called when the About button is tapped.
    var onAbout: () -> Void
    
    /// Called when the Testimonials button is tapped.
    var onTestimonials: () -> Void
    
    /// Called when the Cart button is tapped.
    var onCart: () -> Void
    
    // MARK: - Cart Badge
    /// The current number of items in the cart to display as a badge.
    let cartCount: Int
    
    // MARK: - Category Header
    /// Array of tags (categories) available for filtering.
    let tags: [String]
    
    /// The currently selected tag.
    let selectedTag: String
    
    /// Called when a user selects a tag from the category list.
    /// You might do: Task { await viewModel.filterProducts(by: tag) }
    var onTagSelected: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 1) Brand Row
            brandRow
            
            // 2) Horizontal category row
            categoryRow
        }
        // You can style or background-color this VStack as needed
        // to ensure it looks like a single sticky header.
        .background(Color(.systemBackground).opacity(0.95))
    }
}

// MARK: - Subviews
extension AppHeaderView {
    
    /**
     The top brand row with brand name + About, Testimonials, Cart (with badge).
     */
    private var brandRow: some View {
        HStack {
            // Brand name.
            Text("KAAYKO")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .accessibilityLabel("Kaayko Brand")
            
            Spacer()
            
            // About button.
            Button(action: { onAbout() }) {
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "info.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.primary)
                            .padding(4)
                    )
            }
            .accessibilityLabel("About")
            
            Spacer().frame(width: 8)
            
            // Testimonials button.
            Button(action: { onTestimonials() }) {
                Circle()
                    .strokeBorder(Color.primary, lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "text.bubble")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.primary)
                            .padding(4)
                    )
            }
            .accessibilityLabel("Testimonials")
            
            Spacer().frame(width: 8)
            
            // Cart button with badge overlay.
            ZStack(alignment: .topTrailing) {
                Button(action: { onCart() }) {
                    Circle()
                        .strokeBorder(Color.primary, lineWidth: 1)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "bag")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.primary)
                                .padding(4)
                        )
                }
                .accessibilityLabel("Cart")

                // Badge (only show if cartCount > 0)
                if cartCount > 0 {
                    Text("\(cartCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 8, y: -4)
                        .accessibilityLabel("\(cartCount) items in cart")
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }
    
    /**
     The horizontally scrollable category header (previously `ProductCategoryHeaderView`).
     */
    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(tags, id: \.self) { tag in
                    Button(action: {
                        onTagSelected(tag)
                    }) {
                        Text(tag)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTag == tag ? Color(.systemOrange) : .primary)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .overlay(
                                // Underline the active tag
                                selectedTag == tag ?
                                Rectangle()
                                    .frame(height: 2)
                                    .foregroundColor(Color(.systemOrange))
                                    .offset(y: 12)
                                : nil,
                                alignment: .bottom
                            )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: 44) // Adjust if you need more/less height
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Category filter. Selected: \(selectedTag)")
        .shadow(radius: 2)
    }
}
