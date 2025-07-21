//
//  FullScreenModalView.swift
//  Listen To Water
//
//  Created by Rohan Ramekar on 12/25/23.
//  Updated by ChatGPT on 07/20/25 to use Apple’s AsyncImage
//
import SwiftUI

struct FullScreenModalView: View {
    var card: POCard

    var body: some View {
        VStack {
            handleBar
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(card.additionalImageURLs, id: \.self) { urlString in
                        if let url = URL(string: urlString) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    Text("Loading...")
                                        .frame(height: 300)
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: 300)
                                        .clipped()
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                        .padding(.horizontal)
                                case .failure:
                                    Color.gray
                                        .frame(maxWidth: .infinity, maxHeight: 300)
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                        .padding(.horizontal)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Color.gray
                                .frame(maxWidth: .infinity, maxHeight: 300)
                                .cornerRadius(15)
                                .shadow(radius: 10)
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: gradientBackground()),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .edgesIgnoringSafeArea(.all)
    }

    private var handleBar: some View {
        VStack {
            Rectangle()
                .frame(width: 40, height: 5)
                .foregroundColor(.gray)
                .cornerRadius(3)
                .padding(.top, 6)
                .padding(.bottom, 10)
        }
    }

    // Preserve existing gradient colors function
    private func gradientBackground() -> [Color] {
        // Example gradient, adjust as needed
        return [Color.white, Color.blue]
    }
}
