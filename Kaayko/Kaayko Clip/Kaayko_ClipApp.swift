//  Kaayko_ClipApp.swift
//  Kaayko Clip
//
//  Created by Your Name on 04/22/25.
//
/// The main entry point for the Kaayko App Clip.
///  • Uses universal links or QR codes to extract `productID`
///  • Initializes a purely‑REST SwiftUI `ProductViewModel`
///  • If no `productID` is found, shows a fallback view
import SwiftUI

@main
struct Kaayko_ClipApp: App {
    // deep link state
    @State private var deepLinkProductID: String? = nil
    @State private var productIDFound = false
    
    var body: some Scene {
        WindowGroup {
            ContentView(
                isAppClip: true,
                deepLinkProductID: productIDFound ? deepLinkProductID : nil
            )
            .onOpenURL { url in
                handleIncomingURL(url)
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { ua in
                if let url = ua.webpageURL {
                    handleIncomingURL(url)
                }
            }
        }
    }
    
    /// Parses `productID` query‐param off the incoming URL
    private func handleIncomingURL(_ url: URL) {
        guard
          let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
          let item  = comps.queryItems?.first(where: { $0.name == "productID" }),
          let val   = item.value,
          !val.isEmpty
        else {
            DispatchQueue.main.async {
                self.deepLinkProductID = nil
                self.productIDFound   = false
            }
            return
        }
        DispatchQueue.main.async {
            self.deepLinkProductID = val
            self.productIDFound   = true
        }
    }
}
