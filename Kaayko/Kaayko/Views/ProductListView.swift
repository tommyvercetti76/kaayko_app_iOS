//
//  ProductListView.swift
//  Kaayko
//
//  Displays the carousel of cards.
//  – Full app ⇒ shows all cards and, if `deepLinkProductID` is present,
//    scrolls so the card appears centred (header height taken into account).
//  – App Clip ⇒ waits for the one card, then centres it on screen.
//
import SwiftUI

private let kSideInset:  CGFloat = 16          // 16 pt left & right
private let kHeaderGap:  CGFloat = 108         // sticky header height
private let kExtraNudge: CGFloat =  24         // optics tweak for *true* centre

struct ProductListView: View {

    // MARK: – Dependencies
    @ObservedObject var viewModel: ProductViewModel
    @ObservedObject var kartViewModel: KartViewModel

    let deepLinkProductID: String?
    let isSingleProductMode: Bool               // true in App Clip

    // MARK: – Sheet / modal state
    @State private var showAboutSheet        = false
    @State private var showTestimonialsSheet = false
    @State private var isKartModalPresented  = false

    // MARK: – Body
    var body: some View {
        ZStack {
            if isSingleProductMode { singleProductBody } else { fullListBody }
            if viewModel.isLoading { ProgressView(size: .regular) }
        }
        .overlay(header, alignment: .top)
        .onAppear { viewModel.start() }
        .sheet(isPresented: $isKartModalPresented)  { KartSheetView(kartViewModel: kartViewModel) }
        .sheet(isPresented: $showAboutSheet)        { AboutSheetView() }
        .sheet(isPresented: $showTestimonialsSheet) { TestimonialsSheetView(testimonials: Testimonial.fakeTestimonials) }
    }

    // ───────── HEADER ──────────────────────────────────────────────────────
    private var header: some View {
        AppHeaderView(
            onAbout:        { showAboutSheet        = true },
            onTestimonials: { showTestimonialsSheet = true },
            onCart:         { isKartModalPresented  = true },
            cartCount:      kartViewModel.totalItemCount,
            tags:           viewModel.tags,
            selectedTag:    viewModel.selectedTag,
            onTagSelected:  { tag in Task { await viewModel.filterProducts(by: tag) } },
            isSingleProductMode: isSingleProductMode
        )
    }

    // ───────── FULL APP ────────────────────────────────────────────────────
    @ViewBuilder
    private var fullListBody: some View {
        GeometryReader { geo in
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        Color.clear.frame(height: kHeaderGap)        // spacer
                        ForEach(viewModel.products) { product in
                            ProductCardView(
                                product:       product,
                                viewModel:     viewModel,
                                kartViewModel: kartViewModel,
                                onCartUpdate:  {}
                            )
                            .id(product.productID)
                            .frame(maxWidth: .infinity)              // NEW – keeps L/R equal
                        }
                    }
                    .padding(.horizontal, kSideInset)
                    .padding(.bottom, 24)
                }
                .onAppear  { Task { await scrollIfNeeded(using: proxy, in: geo) } }
                .onChange(of: viewModel.products) { _ in
                    Task { await scrollIfNeeded(using: proxy, in: geo) }
                }
            }
        }
    }

    // ───────── APP CLIP (single card) ─────────────────────────────────────
    @ViewBuilder
    private var singleProductBody: some View {
        GeometryReader { geo in
            if let pid = deepLinkProductID,
               let product = viewModel.products.first(where: { $0.productID == pid }) {
                VStack { Spacer(minLength: 0)
                    ProductCardView(
                        product:       product,
                        viewModel:     viewModel,
                        kartViewModel: kartViewModel,
                        onCartUpdate:  {}
                    )
                    .frame(maxWidth: .infinity)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, kSideInset)
            } else if viewModel.isLoading {
                ProgressView(size: .small)
            } else {
                Text("Product with ID \(deepLinkProductID ?? "unknown") not found.")
                    .font(.headline).padding()
            }
        }
    }

    // ───────── Scroll helper ──────────────────────────────────────────────
    private func scrollIfNeeded(using proxy: ScrollViewProxy,
                                in geo: GeometryProxy) async {
        guard let target = deepLinkProductID, !target.isEmpty else { return }

        // wait (max ~6 s) for the product to arrive
        for _ in 0..<20 where !Task.isCancelled {
            if viewModel.products.contains(where: { $0.productID == target }) {
                // combine anchor with manual y‑offset so the card’s middle
                // appears visually centred below the sticky header
                withAnimation {
                    proxy.scrollTo(target, anchor: .center)
                }
                // nudge to compensate header & shadow
                proxy.scrollTo(target, anchor: .center)
                proxy.scrollTo(target, anchor: UnitPoint(x: 0.5,
                                                         y: 0.5 - (kHeaderGap + kExtraNudge) /
                                                                 geo.size.height))
                return
            }
            try? await Task.sleep(for: .milliseconds(300))
        }
    }
}
