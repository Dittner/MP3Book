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
    @ObservedObject var themeObservable = ThemeObservable.shared

    private var disposeBag: Set<AnyCancellable> = []
    init() {
        SharedContext.shared.run()

        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = .clear
        UIScrollView.appearance().backgroundColor = .clear
        // set backgroundColor to clear makes unable to use background in child views
        // UIView.appearance().backgroundColor = .clear

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
                // UINavigationBar.appearance().tintColor = theme.tint
            }
            .store(in: &disposeBag)
    }

    var body: some Scene {
        WindowGroup {
            ContentView().accentColor(themeObservable.theme.tint.color)
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @ObservedObject var navigator = Navigator.shared
    @ObservedObject var alertBox = AlertBox.shared
    let debugLineColor = UIColor(rgb: 0x00C3FF, alpha: 0.5)

    var body: some View {
        if colorScheme == .dark {
            ThemeObservable.shared.selectDarkTheme()
        } else {
            ThemeObservable.shared.selectLightTheme()
        }
        return GeometryReader { geo in
            ZStack {
                if let pos = navigator.screenPosition.xPosition(id: .bookList) {
                    BookListView()
                        .background(AppBG())
                        .offset(x: pos, y: 0)
                        .transition(.move(edge: navigator.screenPosition.goBack ? .leading : .trailing))
                }

                if let pos = navigator.screenPosition.xPosition(id: .audioFileList) {
                    AudioFileListView()
                        .background(AppBG())
                        .offset(x: pos, y: 0)
                        .transition(.move(edge: navigator.screenPosition.goBack ? .leading : .trailing))
                }

                if let pos = navigator.screenPosition.xPosition(id: .library) {
                    LibraryView()
                        .background(AppBG())
                        .offset(x: pos, y: 0)
                        .transition(.move(edge: navigator.screenPosition.goBack ? .leading : .trailing))
                }

                if let pos = navigator.screenPosition.xPosition(id: .manual) {
                    ManualView()
                        .background(AppBG())
                        .offset(x: pos, y: 0)
                        .transition(.move(edge: navigator.screenPosition.goBack ? .leading : .trailing))
                }

//                Color(debugLineColor).frame(width: 0.5).offset(x: -geo.size.width / 2 + Constants.size.actionBtnSize / 2)
//                Color(debugLineColor).frame(width: 0.5).offset(x: geo.size.width / 2 - Constants.size.actionBtnSize / 2)
//                Color(debugLineColor).frame(width: 0.5).offset(x: 0)
//                Color(debugLineColor).frame(height: 0.5).offset(x: 0)
            }
            .onAppear {
                navigator.appWidth = geo.size.width
            }
            .alert(item: $alertBox.message) { msg in
                Alert(
                    title: Text(msg.title),
                    message: Text(msg.details),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }
}

struct AppBG: View {
    @ObservedObject var themeObservable = ThemeObservable.shared

    var body: some View {
        LinearGradient(gradient: Gradient(colors: themeObservable.theme.appBgColors), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}
