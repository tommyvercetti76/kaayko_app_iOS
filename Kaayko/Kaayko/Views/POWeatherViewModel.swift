//
//  POWeatherViewModel.swift
//  Paddling Out - Weather's View Model
//
//  Created by Rohan Ramekar on 1/19/24.
//

// To control the weather (handling) better
// I'm not God (or government)

import SwiftUI
import UIKit

class POWeatherViewModel: ObservableObject {
    @Published var weather: POCard.Weather
    @Published var showFahrenheit = false
    
    init(weather: POCard.Weather) {
        self.weather = weather
    }
    
    var iconName: String {
        POWeatherIconManager.shared.iconName(for: weather.conditionCode, isNight: !weather.isDay)
    }
    
    var temperature: String {
        formatTemperature(showFahrenheit ? weather.temperatureF : weather.temperatureC)
    }
    
    var feelsLike: String {
        formatTemperature(showFahrenheit ? weather.feelsLikeF : weather.feelsLikeC)
    }
    
    var windSpeed: Double {
        weather.gustMPH
    }
    
    var windMessage: String {
        switch windSpeed {
        case 0..<8:
            return "Calm"
        case 8..<16:
            return "Breezy"
        default:
            return "Windy"
        }
    }
    
    var windScale: CGFloat {
        switch windSpeed {
        case 0..<8:
            return 1.0
        case 8..<16:
            return 1.2
        default:
            return 1.4
        }
    }
    
    var backgroundColor: Color {
        !weather.isDay ? Color.black.opacity(0.7) : Color.white.opacity(0.9)
    }
    
    var textColor: Color {
        !weather.isDay ? Color.white : Color.black
    }
    
    var iconColor: Color {
        POWeatherIconManager.shared.getIconColor(for: weather.conditionCode)
    }
    
    var iconGlow: Color {
        POWeatherIconManager.shared.getIconGlow(for: weather.conditionCode)
    }
    
    var windColor: Color {
        getWindColor(windSpeed)
    }
    
    func toggleTemperatureUnit() {
        withAnimation {
            showFahrenheit.toggle()
        }
    }
    
    func triggerHapticFeedback() {
        let hapticIntensity: UIImpactFeedbackGenerator.FeedbackStyle = {
            switch windSpeed {
            case 0..<8:
                return .soft
            case 8..<16:
                return .medium
            default:
                return .heavy
            }
        }()
        
        let generator = UIImpactFeedbackGenerator(style: hapticIntensity)
        generator.prepare()
        generator.impactOccurred()
    }
    
    private func formatTemperature(_ temperature: Double) -> String {
        "\(Int(temperature.rounded()))°"
    }
    
    private func formatWindSpeed(_ windSpeed: Double, isFahrenheit: Bool) -> String {
        let speedUnit = isFahrenheit ? "mph" : "km/h"
        let speedValue = isFahrenheit ? windSpeed : windSpeed * 1.60934
        return "\(Int(speedValue.rounded())) \(speedUnit)"
    }
    
    private func getWindColor(_ windSpeed: Double) -> Color {
        switch windSpeed {
        case 0..<8:
            return .green
        case 8..<16:
            return .orange
        default:
            return .red
        }
    }
}
