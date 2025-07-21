//  KaaykoProductRepositoryAPI.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 2025-04-22.
//
import Foundation
import Combine

@MainActor
final class KaaykoProductRepositoryAPI: ObservableObject, ProductRepositoryProtocol {

    // MARK: Published stream -------------------------------------------------

    @Published private(set) var allProducts: [Product] = []
    var allProductsPublisher: Published<[Product]>.Publisher { $allProducts }

    // MARK: End‑points & state ----------------------------------------------

    private let baseURL        = URL(string: "https://kaayko.com/api")!
    private let imageProxyBase = URL(string: "https://kaayko.com/api/images")!
    private var cancellables   = Set<AnyCancellable>()

    // MARK: Lifecycle --------------------------------------------------------

    func startListening() { fetchAllProducts() }
    func stopListening()  { /* one‑shot → nothing to cancel */ }

    // MARK: Tag helper -------------------------------------------------------

    func fetchAllTags() -> [String] {
        let unique = Set(allProducts.flatMap(\ .tags))
        return ["All"] + unique.sorted()
    }

    // MARK: Network ----------------------------------------------------------

    /// Downloads and decodes all products - using direct Firebase image URLs
    private func fetchAllProducts() {
        let url = baseURL.appendingPathComponent("products")

        print("🛒 Fetching all products from: \(url.absoluteString)")

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())

            // Use Firebase URLs directly - no proxying needed
            .map { products in
                print("📦 Received \(products.count) products")
                print("🖼️  Sample images from first product: \(products.first?.imgSrc.prefix(2) ?? [])")
                return products
            }

            // On error, provide empty array
            .replaceError(with: [])

            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        print("🚨 Failed to fetch products: \(error)")
                    case .finished:
                        print("✅ Successfully fetched products")
                    }
                },
                receiveValue: { [weak self] products in
                    self?.allProducts = products
                }
            )
            .store(in: &cancellables)
    }

    // MARK: Voting -----------------------------------------------------------

    func updateProductVotes(productId: String, voteChange: Int) async throws {
        guard [1, -1].contains(voteChange) else {
            throw NSError(domain: "Invalid voteChange", code: 400)
        }

        let voteURL = baseURL
            .appendingPathComponent("products")
            .appendingPathComponent(productId)
            .appendingPathComponent("vote")

        print("🗳️ Voting on product '\(productId)' with change \(voteChange) at: \(voteURL.absoluteString)")

        var req = URLRequest(url: voteURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["voteChange": voteChange])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("🚨 Vote failed for product '\(productId)': \(msg)")
            throw NSError(domain: "Vote failed",
                          code: (resp as? HTTPURLResponse)?.statusCode ?? 0,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }

        print("✅ Successfully voted on product '\(productId)'")

        // mutate local cache so UI reflects instantly
        if let idx = allProducts.firstIndex(where: { $0.id == productId }) {
            allProducts[idx].votes += voteChange
        }
    }
}
