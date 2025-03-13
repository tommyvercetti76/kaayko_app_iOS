//
//  ModalHeaderView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on [Date].
//
//  A reusable SwiftUI view for modal headers.
//  Displays a centered title and a close button at the top-right.
//  This header is used in both the About and Testimonials modals.

import SwiftUI

struct ModalHeaderView: View {
    /// The title to display in the header.
    let title: String
    /// Closure called when the close button is tapped.
    let onClose: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                .accessibilityLabel(title)
            Spacer()
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 32))
                    .foregroundColor(.black)
            }
            .padding(.trailing, 16)
            .accessibilityLabel("Close \(title) Modal")
        }
        .padding(.vertical, 12)
        .background(Color.white)
    }
}
