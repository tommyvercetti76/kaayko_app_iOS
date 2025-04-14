//
//  KartItem.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/16/25.
//
//  A data structure representing an item in the cart.
//  Each item references a Product and a quantity.

import Foundation

struct KartItem: Identifiable {
    let id: String
    let product: Product
    var quantity: Int
    let selectedColor: String?
    let selectedSize: String?
    
    init(product: Product, quantity: Int = 1, selectedColor: String? = nil, selectedSize: String? = nil) {
        self.id = product.id
        self.product = product
        self.quantity = max(quantity, 1)
        self.selectedColor = selectedColor
        self.selectedSize = selectedSize
    }
}
