//
//  ProductViewModel.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A ViewModel that listens to the RealtimeProductRepository for changes
//  and provides filtered products for SwiftUI views. It supports filtering by tags
//  and updating vote counts in real time. All operations run on the main actor.
//

import SwiftUI
import Combine

@MainActor
final class ProductViewModel: ObservableObject {
    
    /// The real-time repository providing product data and updates.
    private let repository: ProductRepositoryProtocol
    
    /// A cancellable to hold our subscription to the repository's product publisher.
    private var cancellables = Set<AnyCancellable>()
    
    /// Published array of filtered products to display.
    @Published var products: [Product] = []
    
    /// Published array of tags for filtering.
    @Published var tags: [String] = ["All"]
    
    /// The currently selected tag.
    @Published var selectedTag: String = "All"
    
    /// Indicates loading state (e.g., while we fetch images the first time).
    @Published var isLoading = false
    
    /// Stores any error messages (not strictly required, but helpful for debug).
    @Published var errorMessage: String? = nil
    
    /**
     Initialize with a default RealtimeProductRepository or any other `ProductRepositoryProtocol`.
     - Parameter repository: A repository that exposes `allProductsPublisher`.
     */
    init(repository: ProductRepositoryProtocol = RealtimeProductRepository()) {
        self.repository = repository
        
        // Observe the repository's product list in real time:
        repository.allProductsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] newAllProducts in
                guard let self = self else { return }
                // Re-filter whenever new data arrives
                self.applyTagFilter(to: newAllProducts)
            }
            .store(in: &cancellables)
    }
    
    /**
     Called from ContentView (or anywhere else) to kick off our real-time listener.
     This matches your existing `.onAppear { Task { await productViewModel.loadInitialData() } }`.
     */
    func loadInitialData() async {
        start()
    }
    
    /**
     Begins listening for product changes, sets up initial tags, etc.
     If you'd rather not do this automatically on init, you call `start()` manually here.
     */
    func start() {
        isLoading = true
        repository.startListening()
        
        // We might fetch tags after the listener starts, so do a small delay:
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.updateTags()
        }
    }
    
    /**
     Stop real-time listening if needed (e.g. user logs out). Optional.
     */
    func stop() {
        repository.stopListening()
    }
    
    /**
     Updates the tags from the repository's current product list.
     */
    private func updateTags() {
        let allTags = repository.fetchAllTags()
        tags = allTags
        isLoading = false
    }
    
    /**
     Applies the currently selected tag to the given full product list, storing
     the filtered result in `products`.
     - Parameter allProducts: The unfiltered list from the repository.
     */
    private func applyTagFilter(to allProducts: [Product]) {
        if selectedTag == "All" {
            products = allProducts
        } else {
            products = allProducts.filter { $0.tags.contains(selectedTag) }
        }
    }
    
    /**
     Public method to filter products by a given tag. We store that tag,
     then apply it to the current repository product list.
     - Parameter tag: The tag to filter by.
     */
    func filterProducts(by tag: String) {
        selectedTag = tag
        // The repository’s real-time data is always accessible in `allProductsPublisher`.
        // We can directly read the last snapshot of allProducts from the repository if we have it.
        if let repo = repository as? RealtimeProductRepository {
            applyTagFilter(to: repo.allProducts)
        }
    }
    
    /**
     Updates the vote count for a product. Firestore updates in the background,
     but our real-time listener + local update ensures the user sees immediate changes.
     - Parameter product: The product to update.
     - Parameter voteChange: +1 or -1.
     */
    func updateVotes(for product: Product, voteChange: Int) async {
        do {
            try await repository.updateProductVotes(productId: product.id, voteChange: voteChange)
        } catch {
            print("Error updating votes:", error)
            errorMessage = error.localizedDescription
        }
    }
}
