//
//  AudioFileListView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 18.02.2021.
//

import Combine
import SwiftUI

struct AudioFileListView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var themeObservable = ThemeObservable.shared
    @ObservedObject var vm = AudioFileListVM.shared

    var body: some View {
        ZStack {
            VStack(alignment: .center, spacing: 0) {
                NavigationBar {
                    HStack(alignment: .center, spacing: 0) {
                        IconButton(iconName: "back", iconColor: themeObservable.theme.tint.color) {
                            self.vm.goBack()
                        }

                        Spacer()

                        Text(vm.selectedBook?.title ?? "").bold()
                            .lineLimit(2)
                            .font(Font.m3b.navigationTitle)
                            .foregroundColor(themeObservable.theme.tint.color)

                        Spacer()

                        IconButton(iconName: "sort", iconColor: themeObservable.theme.tint.color) {
                        }
                    }
                }

                FileListContent(vm: vm)
            }

            if vm.playRateSelectorShown {
                PlayRateSelector(isShown: $vm.playRateSelectorShown, selectedRate: vm.selectedBook?.rate ?? 1.0) { rate in
                    self.vm.updateRate(value: rate)
                }
            } else if vm.addBookmarkFormShown, let file = vm.player.book?.curFile {
                AddBookmarkForm(isShown: $vm.addBookmarkFormShown, file: file) { time, comment in
                    self.vm.addBookmark(time: time, comment: comment)
                }
            }
        }
    }
}

struct FileListContent: View {
    @ObservedObject var vm: AudioFileListVM

    init(vm: AudioFileListVM) {
        print("FileListContent")
        self.vm = vm
    }

    var body: some View {
        if vm.isLoading {
            ActivityIndicator(isAnimating: $vm.isLoading)
        } else {
            VStack(alignment: .center, spacing: 0) {
                ScrollView {
                    LazyVStack(alignment: .center, spacing: 1) {
                        ForEach(vm.files) { file in
                            FileCell(f: file) {
                                self.vm.playFile(file)
                            }
                        }
                    }
                }
                .clipped()

                PlayerView(playingBook: vm.selectedBook) { action in
                    switch action {
                    case let .updateProgress(progress):
                        vm.updateProgress(value: progress)
                    case let .play(book):
                        vm.play(book)
                    case .pause:
                        vm.pause()
                    case .playNext:
                        vm.playNext()
                    case .playPrev:
                        vm.playPrev()
                    case .selectRate:
                        vm.playRateSelectorShown = true
                    case .addBookmark:
                        vm.pause()
                        vm.addBookmarkFormShown = true
                    }
                }
            }
        }
    }
}

struct FileCell: View {
    @ObservedObject private var themeObservable = ThemeObservable.shared
    @ObservedObject private var file: AudioFile
    @ObservedObject private var notifier = Notifier()

    class Notifier: ObservableObject {
        @Published var playState: PlayState = .stopped
    }

    let selectAction: () -> Void

    let title: String
    let duration: String

    private var disposeBag: Set<AnyCancellable> = []
    init(f: AudioFile, selectAction: @escaping () -> Void) {
        file = f

        self.selectAction = selectAction
        title = f.name
        duration = DateTimeUtils.secToHHMMSS(f.duration)

        Publishers.CombineLatest(f.book.$playState, f.book.$curFile)
            .map { state, playingFile in
                if playingFile.id == f.id {
                    return state
                } else {
                    return .stopped
                }
            }
            .assign(to: \.playState, on: notifier)
            .store(in: &disposeBag)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer()

            HStack(alignment: .center, spacing: 0) {
                Image(notifier.playState == .playing ? "pause" : "play")
                    .renderingMode(.template)
                    .allowsHitTesting(false)
                    .frame(width: 50)

                Text(title)
                    .font(Font.custom(.helveticaNeue, size: 15))
                    .minimumScaleFactor(11 / 15)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                Text(duration)
                    .font(Font.custom(.helveticaNeue, size: 11))
                    .lineLimit(1)
                    .padding()

            }.frame(maxWidth: .infinity)

            Spacer()

            SeparatorView(horizontalPadding: -50)
        }
        .frame(height: 60)
        .background(themeObservable.theme.transparent.color)
        .foregroundColor(notifier.playState == .stopped ? themeObservable.theme.text.color : themeObservable.theme.play.color)
        .onTapGesture {
            selectAction()
        }
    }
}
