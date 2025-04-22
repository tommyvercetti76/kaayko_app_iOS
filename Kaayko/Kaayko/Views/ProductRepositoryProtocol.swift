//
//  ProductRepositoryProtocol.swift
//  Kaayko
//
//  Created by Your Name on 2025‑04‑22.
//
/// A source‑agnostic contract that both Firestore (legacy) and
/// REST‑API implementations conform to.
//
@preconcurrency   // suppresses “main‑actor‑isolation” warnings for Combine
import Combine

protocol ProductRepositoryProtocol: AnyObject {
    /// Emits the **entire** product list every time it changes.
    var allProductsPublisher: Published<[Product]>.Publisher { get }

    /// Begin producing product updates (one‑shot or live stream).
    func startListening()

    /// End any observation work. (No‑op for the REST implementation.)
    func stopListening()

    /// Extract a unique, sorted tag list from the last product snapshot.
    func fetchAllTags() -> [String]

    /// Increment/decrement votes server‑side and update local cache.
    func updateProductVotes(productId: String, voteChange: Int) async throws
}
