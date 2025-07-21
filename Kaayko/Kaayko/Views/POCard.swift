//
//  POCard.swift
//  Listen To Water
//
//  Created by Rohan Ramekar on 12/11/23.
//

import Foundation

struct POCard: Codable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let text: String
    let imgSrc: [String]  // Changed to match backend API format
    let youtubeURL: String
    let location: Location
    var weather: Weather?
    let parkingAvl: Bool  // Changed to Bool to match API
    let restroomsAvl: Bool  // Changed to Bool to match API
    
    // Computed properties for backward compatibility
    var imageURL: String {
        return imgSrc.first ?? ""
    }
    
    var additionalImageURLs: [String] {
        return Array(imgSrc.dropFirst())
    }

    struct Location: Codable {
        let latitude: Double
        let longitude: Double
    }

    struct Weather: Codable {
        let temperatureC: Double
        let temperatureF: Double
        let gustMPH: Double
        let isDay: Bool
        let conditionText: String
        let feelsLikeC: Double
        let feelsLikeF: Double
        let conditionCode: Int
    }
}
