//
//  RealtimeProductRepository.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A Firestore-based repository that listens in real-time for product changes,
//  merges them with Storage image URLs, and handles vote updates. Suitable for
//  real-time shopping experiences where user votes and product data must stay in sync.
//

import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import Combine
import SwiftUI

/// A protocol describing real-time product operations.
protocol ProductRepositoryProtocol: AnyObject {
    /// A publisher that emits the full list of products whenever Firestore changes.
    var allProductsPublisher: Published<[Product]>.Publisher { get }
    
    /// Starts listening to Firestore in real-time for product changes.
    func startListening()
    
    /// Stops the Firestore listener if needed (e.g. on sign-out).
    func stopListening()
    
    /// Fetches all unique tags from the in-memory product list.
    func fetchAllTags() -> [String]
    
    /// Atomically increments or decrements a product's vote count on Firestore.
    func updateProductVotes(productId: String, voteChange: Int) async throws
}

/// A concrete real-time repository implementation using Firestore + Storage.
final class RealtimeProductRepository: ObservableObject, ProductRepositoryProtocol {
    
    /// Publishes the complete list of products, merged with images and kept up-to-date via Firestore listener.
    @Published private(set) var allProducts: [Product] = []
    var allProductsPublisher: Published<[Product]>.Publisher { $allProducts }
    
    /// Firestore reference.
    private let db = Firestore.firestore()
    
    /// Storage reference (for product images).
    private let storage = Storage.storage()
    
    /// In-memory image cache, keyed by productID.
    private var imageCache: [String: [String]] = [:]
    
    /// Firestore listener registration (so we can stop listening if needed).
    private var listenerRegistration: ListenerRegistration? = nil
    
    // MARK: - Lifecycle
    
    /**
     Starts listening to the "kaaykoproducts" collection in real-time.
     Whenever a document is added/modified/removed, we update `allProducts`.
     */
    func startListening() {
        guard listenerRegistration == nil else { return } // Already listening
        
        listenerRegistration = db.collection("kaaykoproducts")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                if let error = error {
                    print("Error listening to products:", error)
                    return
                }
                guard let documents = snapshot?.documents else {
                    print("No documents in real-time snapshot.")
                    return
                }
                
                // We’ll build a new array of products from the snapshot
                var updatedProducts: [Product] = []
                
                // For each doc, convert to Product
                for doc in documents {
                    let data = doc.data()
                    guard let productID = data["productID"] as? String else {
                        continue
                    }
                    let title = data["title"] as? String ?? ""
                    let desc = data["description"] as? String ?? ""
                    let price = data["price"] as? String ?? ""
                    let votes = data["votes"] as? Int ?? 0
                    let tags = data["tags"] as? [String] ?? []
                    
                    // We'll create a placeholder Product with an empty imgSrc for now.
                    let product = Product(
                        id: doc.documentID,
                        title: title,
                        description: desc,
                        price: price,
                        votes: votes,
                        productID: productID,
                        imgSrc: [],
                        tags: tags
                    )
                    updatedProducts.append(product)
                }
                
                // Merge with existing image cache or fetch images for new productIDs
                self.updateAllProductsWithImages(updatedProducts)
            }
    }
    
    /**
     Stops the Firestore listener (if active).
     Call this if you no longer need real-time updates, e.g. on sign out.
     */
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
    }
    
    /**
     Merges a fresh array of "raw" products (no images) with the in-memory image cache
     or fetches new images if a productID is encountered for the first time.
     Then publishes the final array to `allProducts`.
     
     - Parameter freshProducts: The array of products from the Firestore snapshot (minus images).
     */
    private func updateAllProductsWithImages(_ freshProducts: [Product]) {
        // We'll do an async method for image fetching
        Task {
            var finalList: [Product] = []
            
            // For each raw product from Firestore
            for product in freshProducts {
                let pid = product.productID
                // Check if we have images cached
                if let cached = imageCache[pid] {
                    // We already have them
                    let updated = product.withImages(cached)
                    finalList.append(updated)
                } else {
                    // Need to fetch images from Firebase Storage
                    let images = await fetchImages(productID: pid)
                    imageCache[pid] = images
                    let updated = product.withImages(images)
                    finalList.append(updated)
                }
            }
            
            // Sort or keep order as you'd like. We'll just keep Firestore's snapshot order:
            // finalList is in the same order we got docs.
            
            // Publish final to @Published
            await MainActor.run {
                self.allProducts = finalList
            }
        }
    }
    
    /**
     Helper method to fetch product images from Firebase Storage (folder=productID).
     - Parameter productID: Unique product identifier.
     - Returns: An array of image URL strings.
     */
    private func fetchImages(productID: String) async -> [String] {
        do {
            let storageRef = storage.reference(withPath: "kaaykoStoreTShirtImages/\(productID)")
            let listResult = try await storageRef.listAll()
            
            // Concurrently map items -> downloadURLs
            let urls: [String] = try await withTaskGroup(of: String?.self) { group in
                for item in listResult.items {
                    group.addTask {
                        do {
                            return try await item.downloadURL().absoluteString
                        } catch {
                            print("Error fetching image URL:", error)
                            return nil
                        }
                    }
                }
                var temp: [String] = []
                for await maybeURL in group {
                    if let url = maybeURL {
                        temp.append(url)
                    }
                }
                return temp
            }
            return urls
        } catch {
            print("Error listing product images for \(productID):", error)
            return []
        }
    }
    
    // MARK: - Tags
    
    /**
     Returns all unique tags from our in-memory `allProducts` array, plus "All" at the front.
     */
    func fetchAllTags() -> [String] {
        let uniqueTags = Set(allProducts.flatMap { $0.tags })
        return ["All"] + uniqueTags.sorted()
    }
    
    // MARK: - Vote Updates
    
    /**
     Atomically updates the vote count for a product on Firestore.
     Also updates our local `allProducts` so that the UI sees the immediate change.
     
     - Parameter productId: Firestore document ID.
     - Parameter voteChange: +1 for like, -1 for unlike.
     */
    func updateProductVotes(productId: String, voteChange: Int) async throws {
        let docRef = db.collection("kaaykoproducts").document(productId)
        try await docRef.updateData([
            "votes": FieldValue.increment(Int64(voteChange))
        ])
        
        // We assume the snapshot listener will also reflect this change,
        // but let's update local immediately for snappier UI.
        await MainActor.run {
            if let idx = allProducts.firstIndex(where: { $0.id == productId }) {
                allProducts[idx].votes += voteChange
            }
        }
    }
}
