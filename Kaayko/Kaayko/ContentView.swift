//
//  ContentView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  The main entry point for the app. This view displays the shop view (a vertical scroll of product cards)
//  without a tab bar. All content supports dark/light mode and accessibility.

import SwiftUI

struct ContentView: View {
    // Instantiate the ProductViewModel.
    @StateObject private var viewModel = ProductViewModel()

    var body: some View {
        // Display the ProductListView, which already includes the sticky header overlay.
        ProductListView(viewModel: viewModel)
            .onAppear {
                Task {
                    await viewModel.loadInitialData()
                }
            }
    }
}
