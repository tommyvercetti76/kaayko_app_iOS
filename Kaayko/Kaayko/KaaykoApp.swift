//  KaaykoApp.swift
//  Kaayko
//
//  Created by Your Name on 04/22/25.
//
/// The main SwiftUI entrypoint for the full Kaayko app.
///  • Uses the same URL‐handling as the App Clip
///  • No Firebase SDK is ever initialized—everything is via REST.
import SwiftUI

@main
struct KaaykoApp: App {
    @State private var deepLinkProductID: String? = nil
    
    var body: some Scene {
        WindowGroup {
            ContentView(
              isAppClip: false,
              deepLinkProductID: deepLinkProductID
            )
            .onOpenURL { url in handleIncomingURL(url) }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { ua in
                if let url = ua.webpageURL {
                    handleIncomingURL(url)
                }
            }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard
          let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let item  = comps.queryItems?.first(where: { $0.name == "productID" }),
          let val   = item.value,
          !val.isEmpty
        else {
            DispatchQueue.main.async { self.deepLinkProductID = nil }
            return
        }
        DispatchQueue.main.async {
            self.deepLinkProductID = val
        }
    }
}
