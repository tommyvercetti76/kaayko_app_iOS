//
//  POWeatherIconManager.swift
//  Paddling Out - Weather Icons
//
//  Created by Rohan Ramekar on 1/16/24.
//

// Manages icon display
// for a given condition
// using SF Symbols
// because I'm poor

import SwiftUI

class POWeatherIconManager {
    static let shared = POWeatherIconManager()

    func iconName(for code: Int, isNight: Bool) -> String {
        switch code {
        case 1000: // Sunny/Clear
            return isNight ? "moon.stars.fill" : "sun.max.fill"
        case 1003, 1006: // Partly Cloudy/Cloudy
            return isNight ? "cloud.moon.fill" : "cloud.sun.fill"
        case 1009: // Overcast
            return "cloud.fill"
        case 1030, 1135, 1147: // Mist, Fog, Freezing Fog
            return "cloud.fog.fill"
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201: // Various forms of Rain
            return isNight ? "cloud.moon.rain.fill" : "cloud.sun.rain.fill"
        case 1066, 1210, 1213, 1216, 1219, 1222, 1225: // Various forms of Snow
            return "snowflake.circle.fill"
        case 1069, 1204, 1207, 1249, 1252: // Sleet and related conditions
            return "cloud.sleet.fill"
        case 1072, 1168, 1171: // Freezing Drizzle
            return "cloud.drizzle.fill"
        case 1087, 1273, 1276, 1279, 1282: // Thunderstorms
            return isNight ? "cloud.moon.bolt.fill" : "cloud.sun.bolt.fill"
        case 1114, 1117: // Blowing Snow/Blizzard
            return "wind.snow"
        case 1237, 1261, 1264: // Ice Pellets
            return "cloud.hail.fill"
        case 1240, 1243, 1246: // Rain Showers
            return isNight ? "cloud.moon.rain.fill" : "cloud.sun.rain.fill"
        case 1255, 1258: // Snow Showers
            return "cloud.snow.fill"
        // Additional cases for specific conditions
        default:
            return "cloud" // A generic fallback
        }
    }

    func getIconColor(for conditionCode: Int) -> Color {
        switch conditionCode {
        case 1000:
            return .yellow
        case 1003, 1006:
            return .gray
        case 1009:
            return .blue
        case 1030, 1135, 1147:
            return .gray
        case 1063, 1180, 1183, 1186, 1189, 1192, 1195, 1198, 1201:
            return .blue
        case 1066, 1210, 1213, 1216, 1219, 1222, 1225:
            return .lightBlue
        case 1069, 1204, 1207, 1249, 1252, 1072, 1168, 1171:
            return .gray
        case 1087, 1273, 1276, 1279, 1282:
            return .yellow
        case 1114, 1117:
            return .gray
        case 1237, 1261, 1264:
            return .gray
        case 1240, 1243, 1246:
            return .blue
        case 1255, 1258:
            return .lightBlue
        default:
            return .gray
        }
    }

    func getIconGlow(for conditionCode: Int) -> Color {
        switch conditionCode {
        case 1000, 1003, 1006, 1087, 1273, 1276, 1279, 1282:
            return .yellow.opacity(0.3)
        default:
            return .clear
        }
    }
}
