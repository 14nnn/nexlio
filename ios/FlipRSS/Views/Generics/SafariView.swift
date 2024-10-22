//
//  SafariView.swift
//  FlipRSS
//
//  Created by Darian on 22.10.2024..
//

import SwiftUI
import UIKit
import SafariServices

/// SafariView is a bridge between SafariViewController and SwiftUI.
struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
    }
}
