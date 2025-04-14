//
//  KartViewModel.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/16/25.

//
//  A ViewModel responsible for managing the user's kart state,
//  including adding items, removing items, and updating quantities.

import SwiftUI
import Combine

/// A ViewModel that stores the user's cart items (KartItems) and provides methods to update them.
final class KartViewModel: ObservableObject {
    
    @Published private(set) var items: [KartItem] = []
    
    /**
     Adds a product to the cart or increments its quantity if already present.
     - Parameter product: The product to add or update.
     - Parameter color: optional
     - Parameter size: optional
     */
    func addToCart(product: Product, color: String? = nil, size: String? = nil) {
        if let index = items.firstIndex(where: {
            $0.product.id == product.id && $0.selectedColor == color && $0.selectedSize == size
        }) {
            items[index].quantity += 1
        } else {
            items.append(KartItem(product: product, quantity: 1, selectedColor: color, selectedSize: size))
        }
    }
    
    /**
     Updates the quantity of a cart item. If quantity drops to 0, removes the item.
     - Parameter item: The cart item to update.
     - Parameter delta: The change in quantity (+1 or -1).
     */
    func updateQuantity(for item: KartItem, delta: Int) {
        guard let index = items.firstIndex(where: { $0.id == item.id }) else { return }
        let newQuantity = items[index].quantity + delta
        if newQuantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = newQuantity
        }
    }
    
    /// Returns the total number of items in the cart (sum of quantities).
    var totalItemCount: Int {
        items.reduce(0) { $0 + $1.quantity }
    }
    
    /// Returns a quick sum of prices (assuming `price` is numeric or convertible).
    /// If your `price` is a string like "$25", you might parse it to a Double. Simplified here:
    var totalPrice: Double {
        items.reduce(0) { partial, kartItem in
            let numericPrice = Double(kartItem.product.price.filter("0123456789.".contains)) ?? 0
            return partial + (numericPrice * Double(kartItem.quantity))
        }
    }
}
