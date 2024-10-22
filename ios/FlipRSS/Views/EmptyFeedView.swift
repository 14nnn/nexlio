//
//  EmptyFeedView.swift
//  FlipRSS
//
//  Created by Darian on 22.10.2024..
//

import SwiftUI

/// A view that is displayed when there are no feeds configured in the application.
struct EmptyFeedView: View {
    /// Action to be performed when the add button is tapped
    let onAddTapped: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "newspaper.fill")
                .renderingMode(.original)
                .font(.system(size: 70))
                .foregroundStyle(.gray)
                .padding(.bottom, 10)
            
            Text("No Feeds Yet")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
            
            Text("Add your favorite news sources and start reading")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: onAddTapped) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Your First Feed")
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.white)
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
                .background(Color.blue)
                .cornerRadius(25)
            }
            .padding(.top, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

#Preview {
    EmptyFeedView(onAddTapped: {})
}
