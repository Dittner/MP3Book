//
//  NavigationBarShadow.swift
//  MP3Book
//
//  Created by Alexander Dittner on 22.02.2021.
//

import SwiftUI

struct NavigationBarShadow: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: Color.black.opacity(0.1), radius: 0, x: 0, y: 1)
    }
}

extension View {
    func navigationBarShadow() -> some View {
        ModifiedContent(content: self, modifier: NavigationBarShadow())
    }
}
