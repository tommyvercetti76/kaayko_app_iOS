//
//  ProductViewModel.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A ViewModel that fetches products from the ProductRepository
//  and provides them to SwiftUI views. It supports filtering by tags
//  and updating vote counts. All operations run on the main actor.


import SwiftUI
import Combine

/// A ViewModel for listing and filtering Kaayko products.
@MainActor
final class ProductViewModel: ObservableObject {
    
    /// The repository used for data operations.
    private let repository: ProductRepositoryProtocol
    
    /// Published array of products to display.
    @Published var products: [Product] = []
    
    /// Published array of tags for filtering.
    @Published var tags: [String] = ["All"]
    
    /// The currently selected tag.
    @Published var selectedTag: String = "All"
    
    /// Indicates loading state.
    @Published var isLoading = false
    
    /// Stores any error messages.
    @Published var errorMessage: String? = nil
    
    /// Initialize with a default ProductRepository.
    init(repository: ProductRepositoryProtocol = ProductRepository()) {
        self.repository = repository
    }
    
    /**
     Loads all products and tags from Firebase, updating published properties.
     Sets the loading state during the fetch and resets it afterward.
     */
    func loadInitialData() async {
        isLoading = true
        errorMessage = nil
        do {
            let allProducts = try await repository.fetchAllProducts()
            let allTags = try await repository.fetchAllTags()
            
            products = allProducts
            tags = allTags
            selectedTag = "All"
        } catch {
            print("Error loading data:", error)
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    /**
     Filters products by the specified tag.
     - Parameter tag: The tag to filter by (e.g. "Nostalgia", "All").
     If "All" is selected, all products are returned.
     */
    func filterProducts(by tag: String) async {
        selectedTag = tag
        isLoading = true
        errorMessage = nil
        do {
            let filtered = try await repository.fetchProductsByTag(tag)
            products = filtered
        } catch {
            print("Error filtering by tag:", error)
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    /**
     Updates the vote count for a product.
     - Parameter product: The product to update.
     - Parameter voteChange: +1 for like, -1 for unlike.
     After updating Firestore, the local products array is updated.
     */
    func updateVotes(for product: Product, voteChange: Int) async {
        do {
            try await repository.updateProductVotes(productId: product.id, voteChange: voteChange)
            if let index = products.firstIndex(where: { $0.id == product.id }) {
                products[index].votes += voteChange
            }
        } catch {
            print("Error updating votes:", error)
            errorMessage = error.localizedDescription
        }
    }
}
