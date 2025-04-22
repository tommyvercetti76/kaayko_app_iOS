//
//  KaaykoProductRepositoryAPI.swift
//  Kaayko
//
//  Created by Your Name on 2025‑04‑22.
//
/// REST‑backed repository:
///   • One‑shot GET  /products
///   • Rewrites every signed Storage URL -> /api/images/…
///   • POST   /products/:id/vote
///
import Foundation
import Combine

@MainActor
final class KaaykoProductRepositoryAPI: ObservableObject, ProductRepositoryProtocol {

    // MARK: Published stream -------------------------------------------------

    @Published private(set) var allProducts: [Product] = []
    var allProductsPublisher: Published<[Product]>.Publisher { $allProducts }

    // MARK: End‑points & state ----------------------------------------------

    private let baseURL        = URL(string: "https://us-central1-kaayko-api-dev.cloudfunctions.net/api")!
    private let imageProxyBase = URL(string: "https://us-central1-kaayko-api-dev.cloudfunctions.net/api/images")!
    private var cancellables   = Set<AnyCancellable>()

    // MARK: Lifecycle --------------------------------------------------------

    func startListening() { fetchAllProducts() }
    func stopListening()  { /* one‑shot → nothing to cancel */ }

    // MARK: Tag helper -------------------------------------------------------

    func fetchAllTags() -> [String] {
        let unique = Set(allProducts.flatMap(\.tags))
        return ["All"] + unique.sorted()
    }

    // MARK: Network ----------------------------------------------------------

    /// Downloads, decodes and proxies every image URL.
    private func fetchAllProducts() {
        let proxyBase = imageProxyBase                      // capture by value
        let url       = baseURL.appendingPathComponent("products")

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [Product].self, decoder: JSONDecoder())

            // Replace each signed URL with `/api/images/<pid>/<file>`
            .map { products in
                products.map { product in
                    let proxied = product.imgSrc.compactMap { signed -> String? in
                        guard
                            let signedURL   = URL(string: signed),
                            let decodedPath = signedURL.path.removingPercentEncoding
                        else { return nil }

                        let fileName = decodedPath.components(separatedBy: "/").last ?? ""
                        return proxyBase
                            .appendingPathComponent(product.productID)
                            .appendingPathComponent(fileName)
                            .absoluteString
                    }
                    return product.withImages(proxied)
                }
            }

            .catch { _ in Just([]) }                       // always delivers a value
            .receive(on: DispatchQueue.main)
            .assign(to: \.allProducts, on: self)
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

        var req = URLRequest(url: voteURL)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try JSONEncoder().encode(["voteChange": voteChange])

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, http.statusCode == 200 else {
            let msg = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "Vote failed",
                          code: (resp as? HTTPURLResponse)?.statusCode ?? 0,
                          userInfo: [NSLocalizedDescriptionKey: msg])
        }

        // mutate local cache so UI reflects instantly
        if let idx = allProducts.firstIndex(where: { $0.id == productId }) {
            allProducts[idx].votes += voteChange
        }
    }
}
