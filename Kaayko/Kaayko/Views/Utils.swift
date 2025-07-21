//
//  Utils.swift
//  Listen To Water
//
//  Created by Rohan Ramekar on 4/11/23.
//

import Foundation
import SwiftUI
import Combine
import SafariServices

func gradientBackground() -> [Color] {
    return [Color.blue, Color.darkBlue, Color.black]
}

extension Color {
    static let lightBlue = Color(red: 0.3, green: 0.85, blue: 1.0)
    static let darkBlue = Color(red: 0.1, green: 0.1, blue: 0.3)
    static let darkRed = Color(red: 0.6, green: 0, blue: 0)
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {}
}
