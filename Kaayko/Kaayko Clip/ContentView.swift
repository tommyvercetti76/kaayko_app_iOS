//
//  ContentView.swift
//  Kaayko Clip
//
//  Created by Rohan Ramekar on 3/12/25.
//

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
