//
//  WeatherModels.swift
//  PaddlingOut
//
//  Created by Rohan Ramekar on 4/15/24.
//

import Foundation

// Represents the overall weather data fetched from the API
struct WeatherResponse: Codable {
    let current: CurrentWeather
}

// Represents the current weather details that are part of the API response
struct CurrentWeather: Codable {
    let temp_c: Double
    let temp_f: Double
    let gust_mph: Double
    let is_day: Int
    let condition: WeatherCondition
    let feelslike_c: Double
    let feelslike_f: Double
}

// Represents the weather condition details
struct WeatherCondition: Codable {
    let text: String
    let code: Int
}

