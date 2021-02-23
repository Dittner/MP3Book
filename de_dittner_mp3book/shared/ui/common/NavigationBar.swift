//
//  NavigationBar.swift
//  MP3Book
//
//  Created by Alexander Dittner on 20.02.2021.
//

import SwiftUI

struct NavigationBar<Content: View>: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    @State var content: () -> Content

    var body: some View {
        self.content()
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 60)
            .background(Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: themeObservable.theme.toolbarColors), startPoint: .top, endPoint: .bottom))
                .cornerRadius(radius: 20, corners: [.bottomLeft, .bottomRight])
                .edgesIgnoringSafeArea(.top))
            .zIndex(2)
    }
}
