//  ContentView.swift
//  Kaayko
//
//  Created by Your Name on 04/22/25.
//
/// Shared entrypoint for full app & App Clip.
///  • Always shows the full product list (no deep-link fallback)
///
//  ContentView.swift
import SwiftUI

struct ContentView: View {
    let isAppClip: Bool
    let deepLinkProductID: String?

    @StateObject private var productVM = ProductViewModel()
    @StateObject private var kartVM    = KartViewModel()

    var body: some View {
        ProductListView(
          viewModel:            productVM,
          kartViewModel:        kartVM,
          deepLinkProductID:    deepLinkProductID,
          isSingleProductMode:  isAppClip && (deepLinkProductID != nil)
        )
        .task { await productVM.loadInitialData() }
    }
}
