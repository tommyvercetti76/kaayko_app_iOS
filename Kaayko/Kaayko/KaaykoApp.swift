import SwiftUI
import FirebaseCore

@main
struct KaaykoApp: App {
    @State private var deepLinkProductID: String? = nil
    @State private var showAboutSheet        = false
    @State private var showTestimonialsSheet = false

    init() {
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(
              isAppClip:         false,
              deepLinkProductID: deepLinkProductID
            )
            .sheet(isPresented: $showAboutSheet) {
                AboutSheetView()
            }
            .sheet(isPresented: $showTestimonialsSheet) {
                TestimonialsSheetView(testimonials: Testimonial.fakeTestimonials)
            }
            .onOpenURL(perform: handleIncomingURL)
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { ua in
                if let url = ua.webpageURL {
                    handleIncomingURL(url)
                }
            }
        }
    }

    private func handleIncomingURL(_ url: URL) {
        let path = url.path.lowercased()

        switch path {
          // About sheet on /ul/about or /ul/about.html
          case "/ul/about", "/ul/about.html":
            showAboutSheet = true
            deepLinkProductID = nil

          // Testimonials sheet on /ul/testimonials or /ul/testimonials.html
          case "/ul/testimonials", "/ul/testimonials.html":
            showTestimonialsSheet = true
            deepLinkProductID = nil

          default:
            // Root listing (with optional ?productID) on /ul or /ul/index.html
            if path == "/ul" || path == "/ul/index.html" {
              showAboutSheet = false
              showTestimonialsSheet = false

              // extract ?productID=…
              if let comps = URLComponents(url: url, resolvingAgainstBaseURL: false),
                 let pidItem = comps.queryItems?.first(where: { $0.name == "productID" }),
                 let val = pidItem.value, !val.isEmpty {
                deepLinkProductID = val
              } else {
                deepLinkProductID = nil
              }
            } else {
              // everything else: clear
              deepLinkProductID    = nil
              showAboutSheet        = false
              showTestimonialsSheet = false
            }
        }
    }
}
