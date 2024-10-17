//
//  Notification+Extensions.swift
//  FlipRSS
//
//  Created by Darian on 17.10.2024..
//

import Foundation

extension Notification.Name {
    static let didFlipCardStackView = Notification.Name("didFlipCardStackView")
    static let didPullToRefresh = Notification.Name("didPullToRefresh")
    static let refreshFeeds = Notification.Name("refreshFeeds")
}
