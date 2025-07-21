//
//  POCardScreenView.swift
//  Paddling Out - Landing Screen
//
//  Created by Rohan Ramekar on 12/11/23.

// This displays the Card
// One card at a time
// Page indicator orb glows in distance.

import SwiftUI
import CoreLocation

struct POCardScreenView: View {
    @EnvironmentObject var poViewModel: POViewModel
    @State private var isHorizontal: Bool = true
    @State private var hideDescription: Bool = false
    @State private var showSortModal: Bool = false  // State to manage the presentation of the sort modal
    @State private var showingFullScreen = false

    var body: some View {
        ZStack {
            // Dark gradient background for sleek look
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.08),
                    Color(red: 0.02, green: 0.02, blue: 0.04)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer(minLength: 20)

                if poViewModel.isRestrictedToSingleCard, let selectedCard = poViewModel.selectedCard {
                    // Display only the selected card
                    POCardView(
                        poViewModel: poViewModel,
                        poCard: selectedCard,
                        showDetail: $poViewModel.showDetail,
                        hideDescription: .constant(false)
                    )
                    .frame(width: 340, height: 540)
                    .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            poViewModel.showDetail = true
                        }
                    }
                } else {
                    // Displays cards in horizontal or vertical layout based on `isHorizontal` state
                    if isHorizontal {
                        TabView(selection: $poViewModel.currentPageIndex) {
                            ForEach(0..<poViewModel.poCards.count, id: \.self) { index in
                                POCardView(
                                    poViewModel: poViewModel,
                                    poCard: poViewModel.poCards[index],
                                    showDetail: $poViewModel.showDetail,
                                    hideDescription: .constant(false)
                                )
                                .frame(width: 340, height: 540)
                                .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                                .onTapGesture {
                                    poViewModel.selectedCard = poViewModel.poCards[index]
                                }
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .padding(.horizontal, 16)
                    } else {
                        ScrollView {
                            ForEach(0..<poViewModel.poCards.count, id: \.self) { index in
                                POCardView(
                                    poViewModel: poViewModel,
                                    poCard: poViewModel.poCards[index],
                                    showDetail: $poViewModel.showDetail,
                                    hideDescription: $hideDescription
                                )
                                .frame(width: 340, height: 480)
                                .shadow(color: Color.black.opacity(0.4), radius: 20, x: 0, y: 10)
                                .onTapGesture {
                                    poViewModel.selectedCard = poViewModel.poCards[index]
                                }
                            }
                            .padding(.bottom, 60) // Add padding to ensure the orb is not covered
                        }
                        .onAppear {
                            hideDescription = true
                            poViewModel.setupLocationManager()  // Request location permissions only in list view
                        }
                        .onDisappear {
                            hideDescription = false
                        }
                    }
                }

                Spacer(minLength: 20)

                // Footer with indicator orb
                POIndicatorOrbView(currentPageIndex: $poViewModel.currentPageIndex, totalCards: poViewModel.poCards.count)
                    .onTapGesture {
                        showingFullScreen = true
                    }
            }
            .sheet(isPresented: $showingFullScreen) {
                if let selectedCard = poViewModel.selectedCard {
                    FullScreenModalView(card: selectedCard)
                }
            }
            .sheet(isPresented: $showSortModal) {
//                SortModalView(isPresented: $showSortModal, sortByComfort: poViewModel.sortByComfort, sortByDistance: poViewModel.sortByDistance)
            }
        }
        .onAppear {
            if let selectedCardIndex = poViewModel.poCards.indices.first {
                poViewModel.currentPageIndex = selectedCardIndex
                poViewModel.selectedCard = poViewModel.poCards[selectedCardIndex]
            }
        }
    }
}
