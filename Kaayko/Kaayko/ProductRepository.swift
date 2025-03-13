//
//  ProductRepository.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A repository that fetches product data from Firebase Firestore, merges it with Storage image URLs,
//  and handles vote updates. Implements the ProductRepositoryProtocol.


import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

/// An interface for fetching and updating products.
protocol ProductRepositoryProtocol {
    /// Fetches all products and merges them with their image URLs.
    func fetchAllProducts() async throws -> [Product]
    
    /// Fetches all unique tags from products (plus "All").
    func fetchAllTags() async throws -> [String]
    
    /// Fetches products filtered by a given tag.
    func fetchProductsByTag(_ tag: String) async throws -> [Product]
    
    /// Atomically increments or decrements a product's vote count.
    func updateProductVotes(productId: String, voteChange: Int) async throws
}

/// A concrete implementation of ProductRepositoryProtocol using Firestore and Storage.
final class ProductRepository: ProductRepositoryProtocol {
    
    /// Firestore reference.
    private let db = Firestore.firestore()
    /// Storage reference.
    private let storage = Storage.storage()
    
    /**
     Fetches all products from the "kaaykoproducts" collection,
     merging each with its associated image URLs from Firebase Storage.
     - Returns: An array of `Product` entities.
     */
    func fetchAllProducts() async throws -> [Product] {
        let snapshot = try await db.collection("kaaykoproducts").getDocuments()
        
        // Convert each document to a Product.
        let rawProducts: [Product] = try snapshot.documents.compactMap { doc -> Product? in
            guard let productID = doc.data()["productID"] as? String else { return nil }
            
            let title = doc.data()["title"] as? String ?? ""
            let desc = doc.data()["description"] as? String ?? ""
            let price = doc.data()["price"] as? String ?? ""
            let votes = doc.data()["votes"] as? Int ?? 0
            let tags = doc.data()["tags"] as? [String] ?? []
            
            return Product(
                id: doc.documentID,
                title: title,
                description: desc,
                price: price,
                votes: votes,
                productID: productID,
                imgSrc: [],
                tags: tags
            )
        }
        
        // For each product, fetch its images.
        var finalProducts: [Product] = []
        for rawProd in rawProducts {
            let images = try await fetchImagesByProductId(rawProd.productID)
            let prodWithImages = Product(
                id: rawProd.id,
                title: rawProd.title,
                description: rawProd.description,
                price: rawProd.price,
                votes: rawProd.votes,
                productID: rawProd.productID,
                imgSrc: images,
                tags: rawProd.tags
            )
            finalProducts.append(prodWithImages)
        }
        
        return finalProducts
    }
    
    /**
     Fetches image URLs for a given productID from Firebase Storage.
     - Parameter productID: The product's folder ID in Storage.
     - Returns: An array of download URL strings.
     */
    private func fetchImagesByProductId(_ productID: String) async throws -> [String] {
        let storageRef = storage.reference(withPath: "kaaykoStoreTShirtImages/\(productID)")
        let listResult = try await storageRef.listAll()
        
        // Fetch download URLs concurrently.
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
    }
    
    /**
     Fetches all unique tags from the products, and returns them with "All" at the beginning.
     - Returns: An array of tag strings with "All" as the first element.
     */
    func fetchAllTags() async throws -> [String] {
        let products = try await fetchAllProducts()
        var tagSet = Set<String>()
        products.forEach { product in
            product.tags.forEach { tag in tagSet.insert(tag) }
        }
        return ["All"] + tagSet.sorted()
    }
    
    /**
     Fetches products that contain the specified tag in their `tags` array.
     - Parameter tag: The tag to filter by (e.g. "T-Shirt").
     - Returns: An array of `Product` entities matching the tag.
     */
    func fetchProductsByTag(_ tag: String) async throws -> [Product] {
        guard tag != "All" else {
            return try await fetchAllProducts()
        }
        
        let snapshot = try await db.collection("kaaykoproducts")
            .whereField("tags", arrayContains: tag)
            .getDocuments()
        
        var filteredProducts: [Product] = []
        for doc in snapshot.documents {
            guard let productID = doc.data()["productID"] as? String else { continue }
            let title = doc.data()["title"] as? String ?? ""
            let desc = doc.data()["description"] as? String ?? ""
            let price = doc.data()["price"] as? String ?? ""
            let votes = doc.data()["votes"] as? Int ?? 0
            let tags = doc.data()["tags"] as? [String] ?? []
            
            let images = try await fetchImagesByProductId(productID)
            let product = Product(
                id: doc.documentID,
                title: title,
                description: desc,
                price: price,
                votes: votes,
                productID: productID,
                imgSrc: images,
                tags: tags
            )
            filteredProducts.append(product)
        }
        return filteredProducts
    }
    
    /**
     Atomically updates the vote count for a product.
     - Parameter productId: The Firestore document ID.
     - Parameter voteChange: +1 for like, -1 for unlike.
     */
    func updateProductVotes(productId: String, voteChange: Int) async throws {
        let docRef = db.collection("kaaykoproducts").document(productId)
        try await docRef.updateData([
            "votes": FieldValue.increment(Int64(voteChange))
        ])
    }
}
