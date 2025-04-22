//
//  Product.swift
//  Kaayko
//
//  Created by Your Name on 2025‑04‑22.
//
/// Immutable value type mirroring the JSON returned by:
/// `https://us‑central1‑kaayko‑api‑dev.cloudfunctions.net/api/products`
import Foundation

struct Product: Identifiable, Codable, Equatable {
    /// Firestore document ID (and `/products/:id` identifier)
    let id: String
    /// Marketing title (e.g. “Straight Outta Sabarmati”)
    let title: String
    /// Short copy shown under the title
    let description: String
    /// Display‑only price string (“$$$” etc.)
    let price: String
    /// Current vote count
    var votes: Int
    /// Folder name in Cloud Storage
    let productID: String
    /// **Already‑proxied** image URLs
    let imgSrc: [String]
    /// Free‑form category tags
    let tags: [String]
    /// Available colour swatches
    let availableColors: [String]
    /// Available sizes (S / M / L…)
    let availableSizes: [String]
    /// Max quantity one user can buy
    let maxQuantity: Int
}

extension Product {
    /// Returns a copy with a replaced `imgSrc` array.
    func withImages(_ images: [String]) -> Product {
        Product(id: id,
                title: title,
                description: description,
                price: price,
                votes: votes,
                productID: productID,
                imgSrc: images,
                tags: tags,
                availableColors: availableColors,
                availableSizes: availableSizes,
                maxQuantity: maxQuantity)
    }
}
