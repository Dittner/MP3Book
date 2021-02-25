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
            VStack(alignment: .center, spacing: -20) {
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

                        if vm.selectedBook?.source == .iPodLibrary {
                            IconButton(iconName: "sort", iconColor: themeObservable.theme.tint.color) {
                                vm.resortFiles()
                            }
                        } else {
                            Spacer().frame(width: 50)
                        }
                    }
                }
                
                if let selectedBook = vm.selectedBook {
                    PlayModeTabBar(book: selectedBook)
                        .navigationBarShadow()
                }

                FileListContent(vm: vm)
            }

            if vm.playRateSelectorShown {
                PlayRateSelector(isShown: $vm.playRateSelectorShown, selectedRate: vm.selectedBook?.rate ?? 1.0) { rate in
                    self.vm.updateRate(value: rate)
                }
            } else if vm.addBookmarkFormShown, let file = vm.selectedBook?.coll.curFile {
                AddBookmarkForm(isShown: $vm.addBookmarkFormShown, file: file) { time, comment in
                    self.vm.addBookmark(file: file, time: time, comment: comment)
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
        if let selectedBook = vm.selectedBook {

            VStack(alignment: .center, spacing: -20) {
                FileList(book: selectedBook, vm: vm)

                PlayerView(book: selectedBook) { action in
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

struct PlayModeTabBar: View {
    @ObservedObject private var themeObservable = ThemeObservable.shared
    @ObservedObject var book: Book
    @ObservedObject private var bookmarkColl: BookmarkColl

    init(book: Book) {
        print("PlayModeTabBar init")
        self.book = book
        bookmarkColl = book.bookmarkColl
    }

    func getBookmarksTitle() -> String {
        bookmarkColl.count > 1 ? "\(bookmarkColl.count) bookmarks" : "\(bookmarkColl.count) bookmark"
    }

    func getAudioFilesTitle() -> String {
        book.audioFileColl.count > 1 ? "\(book.audioFileColl.count) audio files" : "\(book.audioFileColl.count) audio file"
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TabBarButton(icon: "bookmark", title: getBookmarksTitle(), theme: themeObservable.theme, selected: book.playMode == .bookmark) {
                if self.book.playMode != .bookmark {
                    self.book.playMode = .bookmark
                }
            }

            TabBarButton(icon: "audioFile", title: getAudioFilesTitle(), theme: themeObservable.theme, selected: book.playMode == .audioFile) {
                if self.book.playMode != .audioFile {
                    self.book.playMode = .audioFile
                }
            }
        }
        .zIndex(1)
        .frame(height: 65)
        .cornerRadius(radius: 20, corners: [.bottomLeft, .bottomRight])
        .padding(.bottom, 0)
    }
}

struct FileList: View {
    @ObservedObject private var book: Book
    @ObservedObject private var bookmarkColl: BookmarkColl

    private let vm: AudioFileListVM

    init(book: Book, vm: AudioFileListVM) {
        self.book = book
        bookmarkColl = book.bookmarkColl
        self.vm = vm
    }

    var body: some View {
        ScrollView {
            Spacer().frame(height: 20)
            LazyVStack(alignment: .center, spacing: 1) {
                if book.playMode == .audioFile {
                    ForEach(book.audioFileColl.files) { file in
                        FileCell(f: file, fileColl: book.audioFileColl) {
                            vm.playFile(file)
                        }
                    }
                } else {
                    ForEach(bookmarkColl.bookmarks) { mark in
                        BookmarkCell(bookmark: mark, coll: bookmarkColl) { action in
                            switch action {
                            case .select:
                                vm.playBookmark(mark)
                            case .delete:
                                vm.removeBookmark(mark)
                            }
                        }
                    }
                }
            }
            Spacer().frame(height: 20)
        }
        .clipped()
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
    init(f: AudioFile, fileColl: AudioFileColl, selectAction: @escaping () -> Void) {
        file = f

        self.selectAction = selectAction
        title = f.name
        duration = DateTimeUtils.secToHHMMSS(f.duration)

        Publishers.CombineLatest(f.book.$playState, fileColl.$curFileIndex)
            .map { state, _ in
                if let playingFile = fileColl.curFile, playingFile == f {
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
                    .font(Font.custom(.helveticaNeue, size: 14))
                    .minimumScaleFactor(12 / 14)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                Spacer()

                Text(duration)
                    .font(Font.custom(.helveticaNeue, size: 12))
                    .lineLimit(1)
                    .padding()

            }.frame(maxWidth: .infinity)

            Spacer()

            HSeparatorView(horizontalPadding: -50)
        }
        .frame(height: 60)
        .background(themeObservable.theme.transparent.color)
        .foregroundColor(notifier.playState == .stopped ? themeObservable.theme.text.color : themeObservable.theme.play.color)
        .onTapGesture {
            selectAction()
        }
    }
}

enum BookmarkCellAction {
    case select
    case delete
}

struct BookmarkCell: View {
    @ObservedObject private var themeObservable = ThemeObservable.shared
    @ObservedObject private var file: AudioFile
    @ObservedObject private var notifier = Notifier()
    @State var offset = CGSize.zero

    class Notifier: ObservableObject {
        @Published var playState: PlayState = .stopped
    }

    let bookmark: Bookmark
    let action: (BookmarkCellAction) -> Void
    let title: String
    let time: String

    private var disposeBag: Set<AnyCancellable> = []
    init(bookmark: Bookmark, coll: BookmarkColl, action: @escaping (BookmarkCellAction) -> Void) {
        self.bookmark = bookmark
        file = bookmark.file

        self.action = action
        title = bookmark.file.name
        time = DateTimeUtils.secToHHMMSS(bookmark.time)

        Publishers.CombineLatest(bookmark.file.book.$playState, coll.$curFileIndex)
            .map { state, _ in
                if let playingMark = coll.curBookmark, playingMark == bookmark {
                    return state
                } else {
                    return .stopped
                }
            }
            .assign(to: \.playState, on: notifier)
            .store(in: &disposeBag)
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()

                    HStack(alignment: .center, spacing: 0) {
                        Image(notifier.playState == .playing ? "pause" : "play")
                            .renderingMode(.template)
                            .allowsHitTesting(false)
                            .frame(width: 50)
                            .animation(.none)

                        Text(time)
                            .font(Font.custom(.helveticaThin, size: 17))
                            .lineLimit(1)
                            .multilineTextAlignment(.leading)

                        VStack(alignment: .leading, spacing: 5) {
                            Text(title)
                                .font(Font.custom(.helveticaNeue, size: 12))
                                .lineLimit(2)
                                .multilineTextAlignment(.leading)

                            if bookmark.comment.count > 0 {
                                Text(bookmark.comment)
                                    .font(Font.custom(.helveticaLight, size: 13))
                                    .lineLimit(20)
                                    .multilineTextAlignment(.leading)
                            }

                        }.padding(.horizontal, 10)
                    }

                    Spacer()

                    HSeparatorView(horizontalPadding: -50)
                }.frame(width: geometry.size.width)

                IconButton(iconName: "delete", iconColor: themeObservable.theme.deleteBtnIcon.color) {
                    self.action(.delete)
                }.frame(width: 70, height: 60)
                    .background(themeObservable.theme.deleteBtnBg.color)

                themeObservable.theme.deleteBtnBg.color.frame(width: -self.offset.width)
            }

            .background(themeObservable.theme.transparent.color)
            .foregroundColor(notifier.playState == .stopped ? themeObservable.theme.text.color : themeObservable.theme.play.color)
            .onTapGesture {
                self.action(.select)
            }
            .offset(self.offset)
            .animation(.spring())
            .gesture(DragGesture()
                .onChanged { gesture in
                    self.offset.width = gesture.translation.width > 0 ? .zero : gesture.translation.width
                }
                .onEnded { _ in
                    if self.offset.width > -50 {
                        self.offset = .zero
                    } else {
                        self.offset = CGSize(width: -70, height: 0)
                    }
                }
            )

        }.frame(maxWidth: .infinity, minHeight: 60, maxHeight: .infinity)
    }
}
