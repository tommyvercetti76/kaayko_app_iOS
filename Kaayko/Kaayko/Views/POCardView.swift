//
//  PaddlingOutCardView.swift
//  Listen To Water
//
//  Created by Rohan Ramekar on 12/11/23.
//

import SwiftUI
import SafariServices
import MapKit

struct POCardView: View {
    @ObservedObject var poViewModel: POViewModel
    let poCard: POCard
    @Binding var showDetail: Bool
    @Binding var hideDescription: Bool

    @State private var showSafariVC: Bool = false
    @State private var currentImageIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            imageCarousel
            
            VStack(alignment: .leading, spacing: 16) {
                titleAndSubtitle

                if !hideDescription {
                    mainCardText
                }

                weatherOrLoading

                FooterButtonsView(
                    poCard: poCard,
                    showSafariVC: $showSafariVC,
                    openMapForPlace: openMapForPlace
                )
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: UIScreen.main.bounds.width - 40)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.1, blue: 0.12),
                    Color(red: 0.05, green: 0.05, blue: 0.08)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
        .sheet(isPresented: $showSafariVC) {
            if let url = URL(string: poCard.youtubeURL) {
                SafariView(url: url)
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                poViewModel.selectedCard = poCard
                poViewModel.showDetail = true
            }
        }
    }

    // MARK: - Image Carousel
    private var imageCarousel: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $currentImageIndex) {
                ForEach(0..<poCard.imgSrc.count, id: \.self) { index in
                    if let url = URL(string: poCard.imgSrc[index]) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 240)
                                    .overlay(
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    )
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(maxWidth: .infinity, maxHeight: 240)
                                    .clipped()
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.5))
                                    .frame(height: 240)
                                    .overlay(
                                        Image(systemName: "photo")
                                            .foregroundColor(.white.opacity(0.7))
                                            .font(.title)
                                    )
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.5))
                            .frame(height: 240)
                    }
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom page indicator for multiple images
            if poCard.imgSrc.count > 1 {
                HStack(spacing: 6) {
                    ForEach(0..<poCard.imgSrc.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentImageIndex ? Color.white : Color.white.opacity(0.4))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentImageIndex ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: currentImageIndex)
                    }
                }
                .padding(.trailing, 16)
                .padding(.bottom, 12)
                .background(
                    Capsule()
                        .fill(Color.black.opacity(0.4))
                        .blur(radius: 8)
                )
                .padding(8)
            }
        }
        .frame(height: 240)
        .cornerRadius(16, corners: [.topLeft, .topRight])
    }

    // MARK: - Title & Subtitle
    private var titleAndSubtitle: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(poCard.title)
                .font(.custom("Yantramanav-Bold", size: 22))
                .foregroundColor(.white)
                .lineLimit(2)

            Text(poCard.subtitle)
                .font(.custom("Yantramanav-Regular", size: 16))
                .foregroundColor(.white.opacity(0.8))
                .lineLimit(3)
        }
    }

    // MARK: - Main Text
    private var mainCardText: some View {
        Text(poCard.text)
            .font(.custom("Yantramanav-Light", size: 15))
            .foregroundColor(.white.opacity(0.9))
            .lineSpacing(2)
            .lineLimit(hideDescription ? 3 : nil)
            .multilineTextAlignment(.leading)
    }

    // MARK: - Weather / Loading
    private var weatherOrLoading: some View {
        Group {
            if let weather = poCard.weather {
                POWeatherView(viewModel: POWeatherViewModel(weather: weather))
            } else {
                Text("Loading weather...")
                    .onAppear { poViewModel.loadWeatherForCard(poCard) }
            }
        }
    }

    // MARK: - Map Launching
    private func openMapForPlace() {
        let regionDistance: CLLocationDistance = 1000
        let coordinates = CLLocationCoordinate2D(
            latitude: poCard.location.latitude,
            longitude: poCard.location.longitude
        )
        let regionSpan = MKCoordinateRegion(
            center: coordinates,
            latitudinalMeters: regionDistance,
            longitudinalMeters: regionDistance
        )
        let options: [String: Any] = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey:   NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "\(poCard.title) Launch Point"
        mapItem.openInMaps(launchOptions: options)
    }
}

// MARK: - View Extensions
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
