//
//  POWeatherFetcher.swift
//  Paddling Out - Weather Fetcher
//
//  Created by Rohan Ramekar on 1/16/24.
//

// Uses free version of Weather API
// Which to be fair is quite liberal
// in their allowance of usage.
// Danke!

import Foundation

class POWeatherFetcher {
    static let shared = POWeatherFetcher()
    private let apiKey = "208c53a237b14e8399d35410241701"
    private let baseURL = "https://api.weatherapi.com/v1/current.json"

    func fetchWeather(forLatitude latitude: Double, longitude: Double, completion: @escaping (Result<POCard.Weather, Error>) -> Void) {
        guard let url = makeURL(forLatitude: latitude, longitude: longitude) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            if let httpResponse = response as? HTTPURLResponse, !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            guard let data = data else {
                completion(.failure(URLError(.dataNotAllowed)))
                return
            }

            do {
                let decoder = JSONDecoder()
                let weatherResponse: WeatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                let weather: POCard.Weather = self.extractWeather(from: weatherResponse.current)
                completion(.success(weather))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func makeURL(forLatitude latitude: Double, longitude: Double) -> URL? {
        let queryString = "?key=\(apiKey)&q=\(latitude),\(longitude)"
        return URL(string: baseURL + queryString)
    }

    private func extractWeather(from currentWeather: CurrentWeather) -> POCard.Weather {
        return POCard.Weather(
            temperatureC: currentWeather.temp_c,
            temperatureF: currentWeather.temp_f,
            gustMPH: currentWeather.gust_mph,
            isDay: currentWeather.is_day == 1,
            conditionText: currentWeather.condition.text,
            feelsLikeC: currentWeather.feelslike_c,
            feelsLikeF: currentWeather.feelslike_f,
            conditionCode: currentWeather.condition.code
        )
    }
}
