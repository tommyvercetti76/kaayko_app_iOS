//
//  BuyPanelView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/30/25.
//
//  A reusable buy panel that displays color, size, and quantity (up to product.maxQuantity).
//  Each row is animated in sequence on appear, and can be animated out in reverse sequence
//  when the user taps "DONE" or the parent signals a close.
//
//  The parent's ProductCardView passes:
//    - shouldClose: toggled to true if user taps the cart again
//    - onClosed: callback used AFTER the reversed subview animations finish
//                 so the parent can set showBuyPanel = false.
//

import SwiftUI

struct BuyPanelView: View {
    // MARK: - External Data
    let product: Product
    @ObservedObject var kartViewModel: KartViewModel
    
    /// Called after user taps "DONE" (to refresh cart, analytics, etc.)
    var onCartUpdate: () -> Void
    
    // MARK: - Parent's Close Coordination
    @Binding var shouldClose: Bool
    var onClosed: () -> Void
    
    // MARK: - User Selections
    @Binding var selectedColor: String?
    @Binding var selectedSize: String?
    @Binding var quantity: Int
    
    // MARK: - Local Animation States
    
    @State private var showColorRow = false
    @State private var showSizeRow  = false
    @State private var showQtyRow   = false
    @State private var showDoneBtn  = false
    
    /// Whether we're reversing subviews out
    @State private var isClosing = false
    
    var body: some View {
        VStack(spacing: 16) {
            
            // 1) Color Row
            if !product.availableColors.isEmpty {
                colorRow
            }
            
            // 2) Size Row
            if !product.availableSizes.isEmpty {
                sizeRow
            }
            
            // 3) Quantity
            quantityRow
            
            // 4) DONE
            doneButton
        }
        .padding(.top, 12)
        .background(Color.white)
        // Called if user re-taps cart
        .onChange(of: shouldClose) { newVal in
            if newVal {
                animateOutAndClose()
            }
        }
        .onAppear {
            animateIn()
        }
    }
}

// MARK: - Subviews
extension BuyPanelView {
    
    private var colorRow: some View {
        HStack {
            Text("Color")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 70, alignment: .leading)
            Spacer()
            
            HStack(spacing: 12) {
                ForEach(product.availableColors, id: \.self) { colorName in
                    Button {
                        selectedColor = colorName
                    } label: {
                        Circle()
                            .fill(colorFromName(colorName))
                            .frame(width: 24, height: 24)
                            .overlay(
                                Circle()
                                    .stroke(
                                        Color.black,
                                        lineWidth: selectedColor == colorName ? 2 : 0
                                    )
                            )
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .opacity(showColorRow ? 1 : 0)
        .offset(y: showColorRow ? 0 : 10)
        .animation(.easeInOut(duration: 0.15).delay(isClosing ? 0.45 : 0.00),
                   value: showColorRow)
    }
    
    private var sizeRow: some View {
        HStack {
            Text("Sizes")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 70, alignment: .leading)
            Spacer()
            
            HStack(spacing: 12) {
                ForEach(product.availableSizes, id: \.self) { size in
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
        .opacity(showSizeRow ? 1 : 0)
        .offset(y: showSizeRow ? 0 : 10)
        .animation(.easeInOut(duration: 0.15).delay(isClosing ? 0.30 : 0.15),
                   value: showSizeRow)
    }
    
    private var quantityRow: some View {
        HStack {
            Text("Quantity")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.black)
                .frame(width: 70, alignment: .leading)
            Spacer()
            
            HStack(spacing: 12) {
                // minus
                Button {
                    if quantity > 1 {
                        quantity -= 1
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(quantity > 1 ? Color.blue : Color.gray.opacity(0.5))
                        .clipShape(Circle())
                }
                .disabled(quantity <= 1)
                
                Text("\(quantity)")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(.black)
                
                // plus
                Button {
                    if quantity < product.maxQuantity {
                        quantity += 1
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 32, height: 32)
                        .background(
                            quantity < product.maxQuantity ? Color.blue : Color.gray.opacity(0.5)
                        )
                        .clipShape(Circle())
                }
                .disabled(quantity >= product.maxQuantity)
            }
        }
        .padding(.horizontal, 16)
        .opacity(showQtyRow ? 1 : 0)
        .offset(y: showQtyRow ? 0 : 10)
        .animation(.easeInOut(duration: 0.15).delay(isClosing ? 0.15 : 0.30),
                   value: showQtyRow)
    }
    
    private var doneButton: some View {
        Button("DONE") {
            // Add items to cart
            for _ in 0..<quantity {
                kartViewModel.addToCart(product: product)
            }
            // Notify parent
            onCartUpdate()
            
            // Animate subviews out in reverse
            animateOutAndClose()
        }
        .font(.system(size: 16, weight: .bold))
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(shouldDisableDone ? Color.gray : Color.green)
        .cornerRadius(8)
        .foregroundColor(.white)
        .padding(.horizontal, 16)
        .padding(.bottom, 12)
        .disabled(shouldDisableDone)
        .opacity(showDoneBtn ? 1 : 0)
        .offset(y: showDoneBtn ? 0 : 10)
        .animation(.easeInOut(duration: 0.15).delay(isClosing ? 0.00 : 0.45),
                   value: showDoneBtn)
    }
}

// MARK: - Animations & Helpers
extension BuyPanelView {
    
    /**
     Disables "DONE" if user hasn't selected required color/size (if needed).
     */
    private var shouldDisableDone: Bool {
        if !product.availableColors.isEmpty && selectedColor == nil {
            return true
        }
        if !product.availableSizes.isEmpty && selectedSize == nil {
            return true
        }
        return false
    }
    
    /**
     Convert color name (e.g. "Red") to SwiftUI Color.
     */
    private func colorFromName(_ name: String) -> Color {
        switch name.lowercased() {
        case "red":   return .red
        case "blue":  return .blue
        case "green": return .green
        default:      return .gray
        }
    }
    
    /**
     Stagger subviews in from t=0.00s → t=0.45s
     */
    private func animateIn() {
        isClosing = false
        
        showColorRow = false
        showSizeRow  = false
        showQtyRow   = false
        showDoneBtn  = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
            showColorRow = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showSizeRow = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            showQtyRow = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            showDoneBtn = true
        }
    }
    
    /**
     Reverse subviews out from t=0.00s → t=0.45s, then remove panel at t=0.60s
     */
    private func animateOutAndClose() {
        guard !isClosing else { return }
        isClosing = true
        
        // Hide done first
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.00) {
            showDoneBtn = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            showQtyRow = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
            showSizeRow = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            showColorRow = false
        }
        
        // Finally remove the panel from the parent
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.60) {
            onClosed()
        }
    }
}
