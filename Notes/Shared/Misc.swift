//
//  Misc.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/12/21.
//

import SwiftUI

// MARK: - Text space

extension Text {
    static let space = Text(verbatim: " ")
}

// MARK: - Default URL

extension URL {
    init() {
        self = URL(string: "about:blank")!
    }
}

// MARK: - Scroll view offset preference key

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}
