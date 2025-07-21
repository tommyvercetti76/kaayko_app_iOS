//
//  POWeatherView.swift
//  Paddling Out - Weather View
//
//  Created by Rohan Ramekar on 1/16/24.
//

// This is displays weather
// Current weather
// for the Current Card
// Watch out for easter eggs

import SwiftUI

struct POWeatherView: View {
    @ObservedObject var viewModel: POWeatherViewModel
    
    var body: some View {
        HStack(spacing: 0) { // set spacing to zero to control spacing with internal spacers
            weatherIconSection
                .frame(maxWidth: .infinity) // Makes this view expand
            Spacer() // Space between weather icon and temperature
            temperatureSection
                .frame(maxWidth: .infinity) // Makes this view expand
            Spacer() // Space between temperature and wind indicator
            windIndicatorSection
                .frame(maxWidth: .infinity) // Makes this view expand
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.black.opacity(0.3))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
        .frame(maxWidth: .infinity)
        .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }

    private var weatherIconSection: some View {
        VStack(alignment: .center, spacing: 4) {
            Image(systemName: viewModel.iconName)
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)
                .foregroundColor(viewModel.iconColor)
                .shadow(color: viewModel.iconGlow, radius: 3, x: 0, y: 2)
        }
    }

    private var temperatureSection: some View {
        VStack(alignment: .center, spacing: 4) {
            HStack(spacing: 4) {
                Text(viewModel.temperature)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                Button(action: viewModel.toggleTemperatureUnit) {
                    unitSwitcher(activeUnit: viewModel.showFahrenheit ? "F" : "C", isDay: viewModel.weather.isDay)
                }
            }
            Text("Feels: \(viewModel.feelsLike)" + (viewModel.showFahrenheit ? "F" : "C"))
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
    }

    private var windIndicatorSection: some View {
        Button(action: viewModel.triggerHapticFeedback) {
            VStack(alignment: .center) {
                Image(systemName: "wind")
                    .resizable()
                    .foregroundColor(viewModel.windColor)
                    .frame(width: 28, height: 28)
                    .shadow(color: viewModel.windColor.opacity(0.5), radius: 2, x: 0, y: 1)
            }
        }
    }

    private func unitSwitcher(activeUnit: String, isDay: Bool) -> some View {
        HStack(spacing: 0) {
            Text("C")
                .font(.system(size: 16, weight: activeUnit == "C" ? .bold : .regular))
                .foregroundColor(activeUnit == "C" ? .white : .white.opacity(0.6))
            Text("|")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white.opacity(0.4))
            Text("F")
                .font(.system(size: 16, weight: activeUnit == "F" ? .bold : .regular))
                .foregroundColor(activeUnit == "F" ? .white : .white.opacity(0.6))
        }
    }
}
