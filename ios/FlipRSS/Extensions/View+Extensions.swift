//
//  View+Extensions.swift
//  FlipRSS
//
//  Created by Darian on 17.10.2024..
//

import SwiftUI

extension View {
    func centerHorizontally() -> some View {
        HStack {
            Spacer()
            self
            Spacer()
        }
    }
}
