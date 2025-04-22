//  ContentView.swift
//  Kaayko
//
//  Created by Your Name on 04/22/25.
//
/// Shared entrypoint for full app & App Clip.
///  • Instantiates the REST‑backed ProductViewModel
///  • Routes to `ProductListView` or a “no ID” fallback
import SwiftUI

struct ContentView: View {
    let isAppClip: Bool
    let deepLinkProductID: String?
    
    @StateObject private var productViewModel = ProductViewModel()
    @StateObject private var kartViewModel    = KartViewModel()
    
    var body: some View {
        Group {
            if isAppClip && deepLinkProductID == nil {
                NoProductFoundView()
            } else {
                ProductListView(
                  viewModel: productViewModel,
                  kartViewModel: kartViewModel,
                  deepLinkProductID: deepLinkProductID,
                  isSingleProductMode: isAppClip && (deepLinkProductID != nil)
                )
                .task { await productViewModel.loadInitialData() }
            }
        }
    }
}

struct NoProductFoundView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("No Product ID Found")
              .font(.title.bold())
            Text("""
                 This App Clip requires a valid `productID`.
                 Please open the full Kaayko app or scan a proper QR code.
                 """)
              .multilineTextAlignment(.center)
              .padding(.horizontal)
            Button("Open Full Kaayko App") {
                UIApplication.shared.open(URL(string: "kaayko://openFullApp")!)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}
