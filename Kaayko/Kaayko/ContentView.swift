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
    @StateObject private var productViewModel = ProductViewModel()
    @StateObject private var kartViewModel = KartViewModel()
    
    var body: some View {
        ProductListView(viewModel: productViewModel, kartViewModel: kartViewModel)
            .onAppear {
                Task {
                    await productViewModel.loadInitialData()
                }
            }
    }
}
