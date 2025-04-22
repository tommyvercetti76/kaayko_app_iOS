//
//  AppHeaderView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
/// A sticky header view with brand name, About/Testimonials/Cart buttons, and a horizontal category row.
/// The category row is hidden if `isSingleProductMode == true`.

import SwiftUI

struct AppHeaderView: View {
    // MARK: - Callbacks
    let onAbout: () -> Void
    let onTestimonials: () -> Void
    let onCart: () -> Void
    
    // MARK: - Cart
    let cartCount: Int
    
    // MARK: - Category
    let tags: [String]
    let selectedTag: String
    let onTagSelected: (String) -> Void
    
    // Hide category row if single-product mode
    let isSingleProductMode: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            brandRow
            if !isSingleProductMode {
                categoryRow
            }
        }
        .background(Color(.systemBackground).opacity(0.95))
    }
    
    private var brandRow: some View {
        // identical to your existing brand row
        HStack {
            Text("KAAYKO")
                .font(.system(size: 20, weight: .bold))
            
            Spacer()
            
            Button(action: onAbout) {
                Circle().strokeBorder(Color.primary, lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "info.circle")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.primary)
                            .padding(4)
                    )
            }
            Spacer().frame(width: 8)
            
            Button(action: onTestimonials) {
                Circle().strokeBorder(Color.primary, lineWidth: 1)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "text.bubble")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.primary)
                            .padding(4)
                    )
            }
            Spacer().frame(width: 8)
            
            ZStack(alignment: .topTrailing) {
                Button(action: onCart) {
                    Circle().strokeBorder(Color.primary, lineWidth: 1)
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "bag")
                                .resizable()
                                .scaledToFit()
                                .foregroundColor(.primary)
                                .padding(4)
                        )
                }
                if cartCount > 0 {
                    Text("\(cartCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(4)
                        .background(Color.red)
                        .clipShape(Circle())
                        .offset(x: 8, y: -4)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }
    
    private var categoryRow: some View {
        // identical to your existing category row
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(tags, id: \.self) { tag in
                    Button(action: { onTagSelected(tag) }) {
                        Text(tag)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(
                                selectedTag == tag ? Color(.systemOrange) : .primary
                            )
                            .padding(.vertical, 8)
                            .padding(.horizontal, 12)
                            .overlay(
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
        .frame(height: 44)
        .shadow(radius: 2)
    }
}
