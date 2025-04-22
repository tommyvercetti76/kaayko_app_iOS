//
//  ProductViewModel.swift
//  Kaayko
//
//  Created by Your Name on 2025‑04‑22.
//
/// High‑level state object used by SwiftUI views.
/// Consumes *any* `ProductRepositoryProtocol`; default is the REST one.
//
import SwiftUI
import Combine

@MainActor
final class ProductViewModel: ObservableObject {

    // MARK: Dependencies -----------------------------------------------------

    private let repository: ProductRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    // MARK: View‑state -------------------------------------------------------

    @Published var products:     [Product] = []
    @Published var tags:         [String]  = ["All"]
    @Published var selectedTag:  String    = "All"
    @Published var isLoading                 = false
    @Published var errorMessage: String?     = nil

    // MARK: Initialisers -----------------------------------------------------

    /// Designated initialiser (DI‑friendly).
    init(repository: ProductRepositoryProtocol) {
        self.repository = repository

        repository.allProductsPublisher
            .sink { [weak self] list in
                self?.applyTagFilter(to: list)
            }
            .store(in: &cancellables)
    }

    /// Convenience: default to REST implementation.
    convenience init() {
        self.init(repository: KaaykoProductRepositoryAPI())
    }

    // MARK: Flow -------------------------------------------------------------

    func loadInitialData() { start() }

    func start() {
        isLoading = true
        repository.startListening()

        // give Combine a tiny moment to deliver the first list
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tags      = self.repository.fetchAllTags()
            self.isLoading = false
        }
    }

    func stop() { repository.stopListening() }

    // MARK: Filtering --------------------------------------------------------

    private func applyTagFilter(to list: [Product]) {
        products = selectedTag == "All"
                 ? list
                 : list.filter { $0.tags.contains(selectedTag) }
    }

    func filterProducts(by tag: String) {
        selectedTag = tag
        applyTagFilter(to: products)
    }

    // MARK: Voting -----------------------------------------------------------

    func updateVotes(for product: Product, voteChange: Int) async {
        do {
            try await repository.updateProductVotes(productId: product.id,
                                                    voteChange: voteChange)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
