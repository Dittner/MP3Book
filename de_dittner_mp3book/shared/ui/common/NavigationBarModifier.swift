//
//  NavigationBarModifier.swift
//  MP3Book
//
//  Created by Alexander Dittner on 08.02.2021.
//

import SwiftUI

struct NavigationBarModifier: ViewModifier {
    let theme: Theme

    init(_ theme: Theme) {
        self.theme = theme
    }

    func body(content: Content) -> some View {
        ZStack {
            content
            VStack {
                GeometryReader { geometry in
                    Rectangle()
                        .fill(LinearGradient(gradient: Gradient(colors: theme.toolbarColors), startPoint: .top, endPoint: .bottom))
                        .cornerRadius(radius: 20, corners: [.bottomLeft, .bottomRight])
                        .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                        
                    //Spacer()
                }
            }.navigationBarTitleDisplayMode(.inline)
        }
    }
}

extension View {
    func navigationBarTheme(_ theme: Theme) -> some View {
        modifier(NavigationBarModifier(theme))
    }
}

struct NavigationViewModifier: ViewModifier {
    var theme: Theme

    init(theme: Theme) {
        self.theme = theme
    }

    func body(content: Content) -> some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: theme.appBgColors), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                .overlay(
                    content
                )
        }
    }
}

extension View {
    func navigationViewTheme(_ theme: Theme) -> some View {
        modifier(NavigationViewModifier(theme: theme))
    }
}
