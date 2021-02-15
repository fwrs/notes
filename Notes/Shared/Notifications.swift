//
//  Notifications.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/14/21.
//

import Foundation

// MARK: - Global application notifications

extension Notification.Name {
    static let noteStateChanged = Self(rawValue: "noteStateChanged")
}

extension Notification {
    static let noteStateChanged = Self(name: Notification.Name(rawValue: "noteStateChanged"))
}
