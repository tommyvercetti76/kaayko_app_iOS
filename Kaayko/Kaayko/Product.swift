//
//  Product.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  Represents a single product in the Kaayko Store.


import Foundation

/// A domain entity representing a Kaayko product.
struct Product: Identifiable {
    /// The unique Firestore document ID.
    let id: String
    /// The product title.
    let title: String
    /// A short product description.
    let description: String
    /// The product price (e.g., "$99").
    let price: String
    /// The number of votes or likes.
    var votes: Int
    /// The unique productID used for Storage references.
    let productID: String
    /// An array of image URLs from Firebase Storage.
    let imgSrc: [String]
    /// An array of tags (categories) associated with the product.
    let tags: [String]
}

/// A simple domain entity for product tags (if needed).
struct Tag: Identifiable {
    let id = UUID()
    let name: String
}
