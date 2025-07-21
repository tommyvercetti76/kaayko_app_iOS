//
//  POViewModel.swift
//  View Model for Paddling Cards
//
//  Created by Rohan Ramekar on 12/11/23.
//

import Foundation
import Combine
import FirebaseCore
import FirebaseStorage
import CoreLocation

class POViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared = POViewModel()

    @Published var poCards: [POCard] = []  // Array of POCard objects that stores all cards.
    @Published var errorMessage: String?  // Stores error messages to display in the UI.
    @Published var selectedCard: POCard?  // The card currently selected or being viewed in detail.
    @Published var showDetail: Bool = false  // Controls whether the detail view is shown.
    @Published var currentPageIndex: Int = 0  // Index of the currently viewed card in a paginated layout.
    @Published var isLoading: Bool = true  // Indicates whether the app is currently loading data.
    @Published var currentLocation: CLLocationCoordinate2D?  // Stores the user's current location
    @Published var isAppClip: Bool = false
    @Published var isRestrictedToSingleCard: Bool = false  // Flag to restrict interaction to a single card

    private var _storageRef: StorageReference?
    private var isFirebaseConfigured = false
    private var storageRef: StorageReference? {
        if _storageRef == nil && isFirebaseConfigured {
            _storageRef = Storage.storage().reference(withPath: "resources/paddling_v1/po_cards.json")
        }
        return _storageRef
    }

    private let cacheLimit: Int = 50
    private var deferredDeepLinkURL: URL?
    private var locationManager: CLLocationManager?

    private override init() {
        super.init()
        // Don't initialize Firebase Storage reference here
        // It will be initialized lazily when needed
    }

    static func initialize(isAppClip: Bool) {
        shared.isAppClip = isAppClip
        shared.loadPaddlingCards()
        shared.loadCachedWeatherData()
    }

    func configureFirebase() {
        isFirebaseConfigured = true
    }

    func setupLocationManager() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestWhenInUseAuthorization()
        locationManager?.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
        }
    }

    func loadPaddlingCards() {
        guard poCards.isEmpty else { return }
        isLoading = true
        
        guard let storageRef = storageRef else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.handleError(NSError(domain: "POViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Firebase Storage not available"]))
            }
            return
        }
        
        storageRef.getData(maxSize: 1 * 1024 * 1024) { [weak self] data, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let error = error {
                    self?.handleError(error)
                    return
                }
                if let data = data {
                    self?.decodePOCards(from: data)
                }
            }
        }
    }

    private func decodePOCards(from data: Data) {
        let decoder = JSONDecoder()
        do {
            let cards = try decoder.decode([POCard].self, from: data)
            DispatchQueue.main.async { [weak self] in
                self?.poCards = cards
                self?.loadWeatherForAllCards()
            }
        } catch {
            DispatchQueue.main.async {
                self.handleError(error)
                self.isLoading = false
            }
        }
    }

    private func loadWeatherForAllCards() {
        let group = DispatchGroup()
        for card in poCards {
            group.enter()
            loadWeatherForCard(card) {
                group.leave()
            }
        }
        group.notify(queue: .main) {
            self.isLoading = false
        }
    }

    func loadWeatherForCard(_ card: POCard, completion: @escaping () -> Void = {}) {
        POWeatherFetcher.shared.fetchWeather(forLatitude: card.location.latitude, longitude: card.location.longitude) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    if let index = self.poCards.firstIndex(where: { $0.id == card.id }) {
                        self.poCards[index].weather = weather
                        self.cacheWeatherData()
                    }
                case .failure(let error):
                    self.handleError(error)
                }
                completion()
            }
        }
    }

    func cacheWeatherData() {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(poCards) {
            UserDefaults.standard.set(encoded, forKey: "CachedWeatherData")
        }
    }

    private func loadCachedWeatherData() {
        guard poCards.isEmpty else { return }  // Load only if poCards is empty
        let decoder = JSONDecoder()
        if let data = UserDefaults.standard.data(forKey: "CachedWeatherData"),
           let decoded = try? decoder.decode([POCard].self, from: data) {
            poCards = decoded
        }
    }

    func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.errorMessage = "An error occurred: \(error.localizedDescription)"
        }
    }

    func selectCard(withID cardID: String?) {
        guard let cardID = cardID, let card = poCards.first(where: { $0.id == cardID }) else {
            DispatchQueue.main.async {
                self.errorMessage = "Card ID \(cardID ?? "unknown") not found."
                self.showErrorMessage()
            }
            return
        }
        DispatchQueue.main.async {
            self.currentPageIndex = self.poCards.firstIndex(where: { $0.id == cardID }) ?? 0
            self.selectedCard = card
            self.showDetail = !self.isAppClip
            if self.isAppClip {
                self.isRestrictedToSingleCard = true
                self.poCards = [card]  // Restrict to this one card
            }
            print("Selected card: \(self.selectedCard?.id ?? "none")")  // Debug log
        }
    }

    func handleQRCode(_ url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard let cardID = components?.queryItems?.first(where: { $0.name == "cardID" })?.value else {
            DispatchQueue.main.async {
                self.errorMessage = "Card ID not found or invalid URL."
                self.showErrorMessage()
            }
            return
        }
        self.selectCard(withID: cardID)
    }

    func showErrorMessage() {
        DispatchQueue.main.async {
            self.showDetail = false
            self.errorMessage = "No card found matching the ID provided."
        }
    }

    func resetToDisplayAllCards() {
        DispatchQueue.main.async {
            self.loadPaddlingCards()
            self.currentPageIndex = 0
            self.showDetail = false
        }
    }

    func handleNavigation(to url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        guard let cardID = components?.queryItems?.first(where: { $0.name == "cardID" })?.value else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL or card ID not found."
                self.showErrorMessage()
            }
            return
        }
        selectCard(withID: cardID)
    }

    // Sort by comfort (both parking and toilet available)
    func sortByComfort() {
        poCards.sort { (card1, card2) -> Bool in
            let comfort1 = (card1.parkingAvl && card1.restroomsAvl) ? 1 : 0
            let comfort2 = (card2.parkingAvl && card2.restroomsAvl) ? 1 : 0
            return comfort1 > comfort2
        }
    }

    // Sort by distance from current location
    func sortByDistance() {
        guard let currentLocation = currentLocation else { return }
        poCards.sort { (card1, card2) -> Bool in
            let distance1 = distance(from: currentLocation, to: card1.location)
            let distance2 = distance(from: currentLocation, to: card2.location)
            return distance1 < distance2
        }
    }

    // Calculate distance between two coordinates
    private func distance(from: CLLocationCoordinate2D, to: POCard.Location) -> CLLocationDistance {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
}
