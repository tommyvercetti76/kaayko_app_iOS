//
//  KartItem.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/16/25.
//
//  A data structure representing an item in the cart.
//  Each item references a Product and a quantity.

import Foundation

/// Represents a single item in the user's cart.
struct KartItem: Identifiable {
    /// The unique identifier of this cart item. Typically the product ID or a composite.
    let id: String
    
    /// The actual product being purchased.
    let product: Product
    
    /// The current quantity of this item.
    var quantity: Int
    
    /// Initializer ensuring no forced unwrapping.
    init(product: Product, quantity: Int = 1) {
        self.id = product.id
        self.product = product
        self.quantity = max(quantity, 1) // Ensure quantity is at least 1
    }
}
