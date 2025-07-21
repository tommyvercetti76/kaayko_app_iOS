//  Kaayko_ClipApp.swift
//  Kaayko Clip
//
//  Created by Rohan Ramekar on 04/22/25.
//

import SwiftUI
import FirebaseCore

@main
struct Kaayko_ClipApp: App {
    /// Holds the incoming ID from the universal link.
    @State private var deepLinkID: String?
    @State private var showPaddlingOut: Bool = false

    /// Use your shared view model throughout.
    @StateObject private var viewModel = POViewModel.shared
    
    /// API repository for paddling spots
    @StateObject private var paddlingAPI = KaaykoPaddlingSpotRepositoryAPI()

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showPaddlingOut, let spotID = deepLinkID {
                    // ─── Paddling Out flow ───
                    POCardScreenView()
                        .environmentObject(viewModel)
                        .onAppear {
                            // Configure for App Clip
                            print("🚀 App Clip starting - Paddling Out mode")
                            print("🎯 Target spot ID: \(spotID)")
                            
                            viewModel.isAppClip = true
                            viewModel.isRestrictedToSingleCard = true
                            
                            // Use REST API
                            paddlingAPI.startListening()
                            paddlingAPI.fetchSpot(byID: spotID)
                        }
                        .onReceive(paddlingAPI.currentSpotPublisher) { spot in
                            if let spot = spot {
                                print("🎯 App Clip received spot: \(spot.title)")
                                // Update the view model with the fetched spot
                                viewModel.poCards = [spot]
                                viewModel.selectedCard = spot
                                viewModel.currentPageIndex = 0
                                
                                // Load weather for the spot
                                viewModel.loadWeatherForCard(spot) { [viewModel] in
                                    // Weather loading completed, update the cards array
                                    if let index = viewModel.poCards.firstIndex(where: { $0.id == spot.id }) {
                                        DispatchQueue.main.async {
                                            // The weather should already be updated by loadWeatherForCard
                                            // but ensure the selected card is also updated
                                            viewModel.selectedCard = viewModel.poCards[index]
                                        }
                                    }
                                }
                            }
                        }
                        .onReceive(paddlingAPI.lastErrorPublisher) { error in
                            if let error = error {
                                print("🚨 App Clip API Error: \(error)")
                            }
                        }

                } else {
                    // ─── Fallback / normal Clip UI ───
                    ContentView(
                        isAppClip:         true,
                        deepLinkProductID: deepLinkID
                    )
                    .environmentObject(viewModel)
                    .onAppear {
                        // Configure for App Clip - products also need Firebase for auth/cart
                        print("🚀 App Clip starting - Product mode")
                        print("🛒 Target product ID: \(deepLinkID ?? "nil")")
                        viewModel.isAppClip = true
                    }
                }
            }
            .onOpenURL(perform: handleIncomingURL(_:))
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: handleUserActivity(_:))
        }
    }

    private func handleIncomingURL(_ url: URL) {
        print("🔗 App Clip handling URL: \(url.absoluteString)")
        
        guard let comps = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            print("❌ Failed to parse URL components")
            showPaddlingOut = false
            deepLinkID = nil
            return
        }

        let path = comps.path.lowercased()
        print("📍 URL path: \(path)")
        print("🔍 Query items: \(comps.queryItems?.map { "\($0.name)=\($0.value ?? "nil")" } ?? [])")
        
        if path.contains("/paddlingout") {
            // Kick off Paddling Out
            showPaddlingOut = true
            deepLinkID = comps.queryItems?
                .first(where: { $0.name.lowercased() == "id" })?
                .value
            print("🌊 Paddling Out mode enabled with spot ID: \(deepLinkID ?? "nil")")
        } else {
            // Legacy productID flow
            showPaddlingOut = false
            deepLinkID = comps.queryItems?
                .first(where: { $0.name.lowercased() == "productid" })?
                .value
            print("🛒 Product mode enabled with product ID: \(deepLinkID ?? "nil")")
        }
    }

    private func handleUserActivity(_ activity: NSUserActivity) {
        if let url = activity.webpageURL {
            handleIncomingURL(url)
        }
    }
}
