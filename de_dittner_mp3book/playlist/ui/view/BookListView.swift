//
//  BookList.swift
//  MP3Book
//
//  Created by Alexander Dittner on 07.02.2021.
//

import Combine
import SwiftUI

struct BookListView: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    @ObservedObject var vm = BookListVM.shared

    var body: some View {
        NavigationView {
            PlaylistContent(vm: vm)
                .toolbar {
//                ToolbarItem(placement: .navigationBarLeading) {
//                    IconButton(iconName: "switchTheme", iconColor: themeObservable.theme.tint.color) {
//                        self.themeObservable.switchTheme()
//                    }
//                }

                    ToolbarItem(placement: .principal) {
                        Text("Playlist").bold()
                            .font(Font.m3b.navigationTitle)
                            .foregroundColor(themeObservable.theme.tint.color)
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        NavigationLink(destination: LibraryView()) {
                            Image("add")
                                .renderingMode(.template)
                        }
                    }
                }
                .navigationViewTheme(themeObservable.theme)
                .navigationBarTheme(themeObservable.theme)
        }
    }
}

struct PlaylistContent: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var vm: BookListVM

    var body: some View {
        if vm.isLoading {
            ActivityIndicator(isAnimating: $vm.isLoading)
        } else {
            ScrollView {
                LazyVStack(alignment: .center, spacing: 1) {
                    ForEach(vm.books) { book in
                        BookCell(b: book)
                    }
                }
            }
            .clipped()
        }
    }
}

struct BookCell: View {
    @ObservedObject private var themeObservable = ThemeObservable.shared
    @ObservedObject private var book: Book
    @ObservedObject private var notifier = Notifier()

    let title: String
    class Notifier: ObservableObject {
        @Published var subtitle: String = ""
    }

    private var disposeBag: Set<AnyCancellable> = []

    init(b: Book) {
        book = b
        title = b.title

        Publishers.CombineLatest(b.$progress, b.$curFileIndex)
            .map { progress, curFileIndex in
                let time = DateTimeUtils.secToHHMMSS(progress)
                let totalDuration = DateTimeUtils.secToHHMMSS(b.totalDuration)
                return "\(curFileIndex + 1) / \(b.files.count), \(time)/\(totalDuration)"
            }
            .assign(to: \.subtitle, on: notifier)
            .store(in: &disposeBag)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("play")
                .renderingMode(.template)
                .allowsHitTesting(false)
                .frame(width: 50)

            VStack(alignment: .center, spacing: 2) {
                Spacer()

                Text(title)
                    .font(Font.custom(.helveticaNeue, size: 17))
                    .minimumScaleFactor(11 / 17)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(self.notifier.subtitle)
                    .font(Font.custom(.helveticaNeue, size: 12))
                    .lineLimit(1)

                Spacer()

                SeparatorView()

            }.frame(maxWidth: .infinity)

            Image("open")
                .renderingMode(.template)
                .allowsHitTesting(false)
                .frame(width: 50)
        }
        .frame(height: 70)
        .background(themeObservable.theme.transparent.color)
        .foregroundColor(book.playState == .stopped ? themeObservable.theme.text.color : themeObservable.theme.play.color)
        .onTapGesture {
            // selected.toggle()
        }
    }
}
