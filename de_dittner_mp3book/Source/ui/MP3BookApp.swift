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
    let context: MP3BookContextProtocol
    @ObservedObject var themeManager: ThemeManager

    private var disposeBag: Set<AnyCancellable> = []
    init() {
        logAbout()

        #if UITESTING
            context = StubMP3BookContext()
        #else
            context = MP3BookContext()
            context.app.demoFileService.addDemoFilesIfNeeded()
        #endif

        themeManager = context.ui.themeManager
    }

    var body: some Scene {
        WindowGroup {
            ContentView(context: context)
                .environmentObject(themeManager)
                .environmentObject(context.ui.systemVolume)
                .accentColor(themeManager.theme.tint.color)
        }
    }
}

struct ContentView: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var themeManager: ThemeManager
    @ObservedObject var navigator: Navigator
    @ObservedObject var alertBox: AlertBox
    let debugLineColor = UIColor(rgb: 0x00C3FF, alpha: 0.5)
    let viewModels: MP3BookContext.UI.VM

    init(context: MP3BookContextProtocol) {
        viewModels = context.ui.viewModels
        navigator = context.ui.navigator
        alertBox = context.app.alertBox
    }

    var body: some View {
        if colorScheme == .dark {
            themeManager.selectDarkTheme()
        } else {
            themeManager.selectLightTheme()
        }
        return GeometryReader { geo in
            ZStack {
                if let pos = navigator.screenPosition.xPosition(id: .bookList) {
                    BookListView(vm: viewModels.bookListVM)
                        .background(AppBG())
                        .offset(x: pos, y: 0)
                        .transition(.move(edge: navigator.screenPosition.goBack ? .leading : .trailing))
                }

                if let pos = navigator.screenPosition.xPosition(id: .audioFileList) {
                    AudioFileListView(vm: viewModels.fileListVM)
                        .background(AppBG())
                        .offset(x: pos, y: 0)
                        .transition(.move(edge: navigator.screenPosition.goBack ? .leading : .trailing))
                }

                if let pos = navigator.screenPosition.xPosition(id: .library) {
                    LibraryView(vm: viewModels.libraryVM)
                        .background(AppBG())
                        .offset(x: pos, y: 0)
                        .transition(.move(edge: navigator.screenPosition.goBack ? .leading : .trailing))
                }

                if let pos = navigator.screenPosition.xPosition(id: .manual) {
                    ManualView(vm: viewModels.manualVM)
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
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        LinearGradient(gradient: Gradient(colors: themeManager.theme.appBgColors), startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
    }
}
