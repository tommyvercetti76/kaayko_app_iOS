//
//  SplashScreenView.swift
//  PaddlingOut
//
//  Created by Rohan Ramekar on 4/21/24.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var viewModel: POViewModel

    @State private var opacity = 1.0

    var body: some View {
        VStack {
            Text("Wear a Life Jacket!")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text("Why sink like an anchor when you can float with a life jacket?")
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.gray)
                .padding(.bottom, 20)
            
            if viewModel.isLoading {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(red: 1.0, green: 1.0, blue: 0.941)) // Ivory color
        .edgesIgnoringSafeArea(.all)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                self.opacity = viewModel.isLoading ? 1.0 : 0.0
            }
        }
        .onChange(of: viewModel.isLoading) { isLoading in
            withAnimation(.easeInOut(duration: 0.5)) {
                self.opacity = isLoading ? 1.0 : 0.0
            }
        }
    }
}
