//
//  AboutModalView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//  A SwiftUI view that displays the About modal overlay.
//  The modal appears as a full‑screen overlay with a dark background.
//  It includes a header with the title “About Kaayko” and a close button,
//  plus a scrollable content area with our Vision & Mission statement.
//  The view supports accessibility, dynamic type, and both dark/light modes.

import SwiftUI

struct AboutModalView: View {
    /// Binding controlling whether the modal is presented.
    @Binding var isPresented: Bool

    var body: some View {
        ZStack {
            // Full-screen dark overlay.
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .accessibilityHidden(true)
            
            // Modal container with fixed dimensions and internal padding.
            VStack(spacing: 0) {
                // Modal header.
                ModalHeaderView(title: "About Kaayko") {
                    withAnimation { isPresented = false }
                }
                
                // Scrollable content for About information.
                ScrollView {
                    VStack(spacing: 16) {
                        Text("Our Vision & Mission")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                            .accessibilityAddTraits(.isHeader)
                        
                        Text("At Kaayko, we strive to bring timeless quality and modern design into every product we create. Our mission is to empower individuality through sustainable craftsmanship and innovative style. We believe that true self‐expression comes from wearing products that not only look great but are built to last.")
                            .font(.system(size: 16, weight: .regular))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.center)
                    }
                    .padding(20)  // Aesthetic internal padding.
                }
                .background(Color.white)
            }
            .frame(width: UIScreen.main.bounds.width * 0.9,
                   height: UIScreen.main.bounds.height * 0.8)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(radius: 6)
            .transition(.scale)
            .accessibilityElement(children: .contain)
        }
    }
}

struct AboutModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AboutModalView(isPresented: .constant(true))
                .preferredColorScheme(.light)
            AboutModalView(isPresented: .constant(true))
                .preferredColorScheme(.dark)
        }
    }
}
