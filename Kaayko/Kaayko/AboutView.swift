//
//  AboutView.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("About Kaayko")
                    .font(.title)
                    .padding()
                
                // Your content: brand philosophy, testimonials, etc.
                Spacer()
            }
            .navigationBarTitle("About", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
