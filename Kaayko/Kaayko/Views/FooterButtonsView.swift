//
//  FooterButtonsView.swift
//  PaddlingOut
//
//  Created by Rohan Ramekar on 4/16/24.
//

import SwiftUI
import MapKit

struct FooterButtonsView: View {
    var poCard: POCard
    var showSafariVC: Binding<Bool>
    var openMapForPlace: () -> Void
    @State private var showMessage: String? = nil
    @State private var messageColor: Color = .green

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()

                // Use ParkingIcon for parking availability
                parkingButton(available: poCard.parkingAvl, availableMessage: "Parking Available", unavailableMessage: "Parking Unavailable")

                Spacer()

                amenitiesButton(systemIconName: "toilet", available: poCard.restroomsAvl, availableMessage: "Toilets Available", unavailableMessage: "Toilet Unavailable")

                Spacer()

                FooterButton(action: {
                    if URL(string: poCard.youtubeURL) != nil {
                        showSafariVC.wrappedValue = true
                    }
                }, iconName: "video.circle.fill", iconColor: .red)
                .frame(width: 48, height: 48)

                Spacer()

                FooterButton(action: openMapForPlace, iconName: "mappin.and.ellipse", iconColor: .green)
                .frame(width: 48, height: 48)

                Spacer()
            }
            .padding(.horizontal, 8)

            if let message = showMessage {
                Text(message)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(messageColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color.black.opacity(0.8))
                    )
                    .transition(.scale.combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showMessage = nil
                            }
                        }
                    }
            }
        }
        .padding(.vertical, 8) // Extra space at the top and bottom
    }

    // Use ParkingIcon for parking availability
    @ViewBuilder
    private func parkingButton(available: Bool, availableMessage: String, unavailableMessage: String) -> some View {
        Button(action: {
            withAnimation {
                showMessage = available ? availableMessage : unavailableMessage
                messageColor = available ? .green : .red
            }
        }) {
            if available {
                ParkingIcon()
                    .frame(width: 48, height: 48)
            } else {
                ParkingIcon()
                    .frame(width: 48, height: 48)
                    .overlay(SlashOverlay())
            }
        }
        .buttonStyle(PlainButtonStyle())  // Ensures the button doesn't show a pressed state which might conflict visually
    }

    @ViewBuilder
    private func amenitiesButton(systemIconName: String, available: Bool, availableMessage: String, unavailableMessage: String) -> some View {
        Button(action: {
            withAnimation {
                showMessage = available ? availableMessage : unavailableMessage
                messageColor = available ? .green : .red
            }
        }) {
            ZStack {
                Circle()
                    .fill(available ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                    .overlay(
                        Circle()
                            .stroke(available ? Color.green : Color.gray, lineWidth: 2)
                    )
                    .frame(width: 48, height: 48)
                
                Image(systemName: systemIconName)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                
                if !available {
                    SlashOverlay()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }

    struct SlashOverlay: View {
        var body: some View {
            GeometryReader { geometry in
                Path { path in
                    let width = geometry.size.width
                    let height = geometry.size.height
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLine(to: CGPoint(x: width, y: height))
                }
                .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .foregroundColor(.red)
            }
        }
    }
}

struct FooterButton: View {
    let action: () -> Void
    let iconName: String
    let iconColor: Color
    
    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(.white)
                .frame(width: 48, height: 48)
                .background(
                    Circle()
                        .fill(iconColor.opacity(0.2))
                        .overlay(
                            Circle()
                                .stroke(iconColor, lineWidth: 1.5)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ParkingIcon: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue.opacity(0.2))
                .overlay(
                    Circle()
                        .stroke(Color.blue, lineWidth: 2)
                )
                .frame(width: 48, height: 48)
            Text("P")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
