//
//  ContentView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  The main entry point. It creates the ProductListView with both ProductViewModel
//  and KartViewModel, so the user can add products to the cart or open the cart overlay.
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
