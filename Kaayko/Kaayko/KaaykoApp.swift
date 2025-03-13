//
//  KaaykoApp.swift
//  Kaayko
//
//  Created by Rohan Ramekar on 3/12/25.
//

import SwiftUI
import Firebase

@main
struct KaaykoApp: App {
    
    init() {
            FirebaseApp.configure() // Initialize Firebase here.
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
