//
//  MP3BookApp.swift
//  MP3Book
//
//  Created by Alexander Dittner on 01.02.2021.
//

import Combine
import SwiftUI

@main
struct MP3BookApp: App {
    let b: Bootstrap

    private var disposeBag: Set<AnyCancellable> = []
    init() {
        b = Bootstrap()

        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UIScrollView.appearance().backgroundColor = .clear
         UIView.appearance().backgroundColor = .clear

        ThemeObservable.shared.$theme
            .sink { theme in
                let coloredAppearance = UINavigationBarAppearance()
                coloredAppearance.configureWithTransparentBackground()
                coloredAppearance.backgroundColor = .clear
                coloredAppearance.titleTextAttributes = [.foregroundColor: theme.tint]
                coloredAppearance.largeTitleTextAttributes = [.foregroundColor: theme.tint]

                UINavigationBar.appearance().standardAppearance = coloredAppearance
                UINavigationBar.appearance().compactAppearance = coloredAppearance
                UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
                // set tintColor to theme.tint kill toolbar custom buttons after a model sheet is dismissed
                //UINavigationBar.appearance().tintColor = theme.tint
            }
            .store(in: &disposeBag)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        if colorScheme == .dark {
            ThemeObservable.shared.selectDarkTheme()
        } else {
            ThemeObservable.shared.selectLightTheme()
        }
        return BookListView()
    }
}
