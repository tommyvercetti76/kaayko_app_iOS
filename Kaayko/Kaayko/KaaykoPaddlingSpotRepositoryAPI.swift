//  KaaykoPaddlingSpotRepositoryAPI.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 2025-07-20.
//
/// REST-backed repository for the "Paddling Out" spots API:
///   • One-shot GET  /paddlingOut         → list all paddling spots
///   • One-shot GET  /paddlingOut/:id     → details for one spot
///
import Foundation
import Combine

@MainActor
final class KaaykoPaddlingSpotRepositoryAPI: ObservableObject {
    // MARK: Published stream -------------------------------------------------

    /// All available paddling spots
    @Published private(set) var allSpots: [POCard] = []
    var allSpotsPublisher: Published<[POCard]>.Publisher { $allSpots }

    /// Single spot detail (if needed)
    @Published private(set) var currentSpot: POCard?
    var currentSpotPublisher: Published<POCard?>.Publisher { $currentSpot }
    
    /// Error handling
    @Published private(set) var lastError: Error?
    var lastErrorPublisher: Published<Error?>.Publisher { $lastError }

    // MARK: Endpoints & state ------------------------------------------------

    private let baseURL      = URL(string: "https://kaayko.com/api")!
    private var cancellables = Set<AnyCancellable>()
    
    // Custom JSON decoder for consistent date/data handling
    private let jsonDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        // Add any custom decoding strategies if needed
        return decoder
    }()

    // MARK: Lifecycle --------------------------------------------------------
    
    /// Start fetching all spots
    func startListening() { fetchAllSpots() }
    /// No ongoing listener to cancel
    func stopListening()  { /* nothing to cancel for one-shot calls */ }

    // MARK: Network ----------------------------------------------------------

    /// Downloads and decodes all paddling spots
    private func fetchAllSpots() {
        // Note: endpoint is /paddlingOut per your index.js
        let url = baseURL.appendingPathComponent("paddlingOut")
        print("🌊 Fetching all paddling spots from: \(url.absoluteString)")
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: [POCard].self, decoder: jsonDecoder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print("🚨 Failed to fetch all spots: \(error)")
                        self?.lastError = error
                        self?.allSpots = [] // Provide empty array on error
                    case .finished:
                        print("✅ Successfully fetched all spots")
                        self?.lastError = nil
                    }
                },
                receiveValue: { [weak self] spots in
                    print("📍 Received \(spots.count) paddling spots")
                    self?.allSpots = spots
                }
            )
            .store(in: &cancellables)
    }

    /// Fetches a single spot by ID
    func fetchSpot(byID id: String) {
        let url = baseURL
            .appendingPathComponent("paddlingOut")
            .appendingPathComponent(id)
        
        print("🎯 Fetching single spot with ID '\(id)' from: \(url.absoluteString)")

        URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .decode(type: POCard.self, decoder: jsonDecoder)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        print("🚨 Failed to fetch spot '\(id)': \(error)")
                        self?.lastError = error
                        self?.currentSpot = nil
                    case .finished:
                        print("✅ Successfully fetched spot '\(id)'")
                        self?.lastError = nil
                    }
                },
                receiveValue: { [weak self] spot in
                    print("📍 Received spot: \(spot.title)")
                    self?.currentSpot = spot
                }
            )
            .store(in: &cancellables)
    }
}
