//
//  ContentView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  The main entry point for the app. This view displays the shop view (a vertical scroll of product cards)
//  without a tab bar. All content is accessible and adapts to dark/light mode.


import SwiftUI

struct ContentView: View {
    // Instantiate the ProductViewModel for data and filtering.
    @StateObject private var viewModel = ProductViewModel()
    
    var body: some View {
        // Display only the product list view.
        ProductListView(viewModel: viewModel)
            .ignoresSafeArea(edges: .bottom)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
