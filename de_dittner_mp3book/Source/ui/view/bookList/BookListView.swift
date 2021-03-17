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
        ZStack {
            VStack(alignment: .center, spacing: -20) {
                NavigationBar { navigationBarSideWidth in
                    Text("Playlist")
                        .font(Constants.font.b16)
                        .foregroundColor(themeObservable.theme.tint.color)
                        .navigationBarTitle(navigationBarSideWidth)

                    IconButton(name: .add, size: 18, color: themeObservable.theme.navigation.color) {
                        self.vm.addBooks()
                    }.accessibilityIdentifier("addBooks")
                        .navigationBarTrailing(navigationBarSideWidth)
                }
                .navigationBarShadow()

                PlaylistContent(vm: vm)
            }

            if vm.playRateSelectorShown {
                PlayRateSelector(isShown: $vm.playRateSelectorShown, selectedRate: vm.selectedBook?.rate ?? 1.0) { rate in
                    self.vm.updateRate(value: rate)
                }
            } else if vm.addBookmarkFormShown, let file = vm.selectedBook?.coll.curFile {
                AddBookmarkForm(isShown: $vm.addBookmarkFormShown, file: file) { time, comment in
                    self.vm.addBookmark(time: time, comment: comment, file: file)
                }
            }
        }
    }
}

struct PlayRateSelector: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    private let selectAction: (Float) -> Void
    private let selectedRate: Float
    @Binding var isShown: Bool

    static let playRates: [Float] = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0]

    init(isShown: Binding<Bool>, selectedRate: Float, selectAction: @escaping (Float) -> Void) {
        _isShown = isShown
        self.selectedRate = selectedRate
        self.selectAction = selectAction
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    self.isShown = false
                }

            VStack(alignment: .center, spacing: 0) {
                Spacer()

                VStack(alignment: .center, spacing: 0) {
                    Text("Tempo")
                        .padding(.vertical, 7)
                        .font(Constants.font.r16)

                    ForEach(PlayRateSelector.playRates, id: \.self) { value in
                        HSeparatorView()
                        Text(value.description)
                            .font(selectedRate == value ? Constants.font.b14 : Constants.font.r14)
                            .padding(.vertical, 8)
                            .onTapGesture {
                                self.selectAction(value)
                                self.isShown = false
                            }
                    }

                }.padding(.horizontal, 20)
                    .frame(width: Constants.size.playRateSelectorWidth)
                    .foregroundColor(themeObservable.theme.tint.color)
                    .lineLimit(1)

                    .background(themeObservable.theme.popupBg.color)
                    .cornerRadius(20)

                DownArrow()
                    .fill(themeObservable.theme.popupBg.color)
                    .frame(width: 25, height: 15)
                    .offset(y: -2)

                Spacer().frame(height: Constants.size.playerHeight * 0.55)
            }.shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 10)
        }
    }
}

struct AddBookmarkForm: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    @ObservedObject private var notifier = Notifier()
    @Binding var isShown: Bool

    class Notifier: ObservableObject {
        @Published var time: Int = 0
        @Published var comment: String = ""
    }

    private let file: AudioFile
    private let title: String
    private let action: (Int, String) -> Void

    init(isShown: Binding<Bool>, file: AudioFile, action: @escaping (Int, String) -> Void) {
        print("AddBookmarkForm init")
        _isShown = isShown
        self.action = action
        self.file = file
        let coll = file.book!.coll
        title = (coll.curFileIndex + 1).description + "/" + coll.count.description + ": " + file.name
        notifier.time = coll.curFileProgress
    }

    func decreaseTime() {
        notifier.time = notifier.time >= 5 ? notifier.time - 5 : 0
    }

    func increaseTime() {
        notifier.time = notifier.time < file.duration - 5 ? notifier.time + 5 : file.duration
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()
                .onTapGesture {
                    self.isShown = false
                }

            VStack(alignment: .center, spacing: 0) {
                Text(title)
                    .font(Constants.font.r14)
                    .lineLimit(2)

                HStack(alignment: .center, spacing: 0) {
                    IconButton(name: .back, size: 18, color: themeObservable.theme.tint.color) {
                        self.decreaseTime()
                    }

                    Text(DateTimeUtils.secToHHMMSS(notifier.time))
                        .font(Constants.font.t26)
                        .lineLimit(1)

                    IconButton(name: .next, size: 18, color: themeObservable.theme.tint.color) {
                        self.increaseTime()
                    }
                }

                VStack(alignment: .leading, spacing: -20) {
                    if notifier.comment.count == 0 {
                        Text("Optional comment")
                            .font(Constants.font.r14)
                            .lineLimit(1)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .foregroundColor(themeObservable.theme.inputText.color)
                            .frame(height: 20, alignment: .topLeading)
                    }

                    TextEditor(text: $notifier.comment)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.horizontal, 10)
                        .font(Constants.font.r14)
                        .background(RoundedRectangle(cornerRadius: 4).fill(themeObservable.theme.inputBg.color))
                        .foregroundColor(themeObservable.theme.inputText.color)
                        .frame(height: Constants.size.popupWidth / 3)
                }

                TextButton(text: "Add Bookmark", textColor: themeObservable.theme.tint.color, font: Constants.font.b14) {
                    self.action(notifier.time, notifier.comment)
                    self.isShown = false
                }

            }.padding(.horizontal, 20)
                .padding(.top, 20)
                .frame(width: Constants.size.popupWidth)
                .foregroundColor(themeObservable.theme.tint.color)
                .background(themeObservable.theme.popupBg.color)
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 10)
        }
    }
}

struct PlaylistContent: View {
    @ObservedObject var vm: BookListVM

    init(vm: BookListVM) {
        print("PlaylistContent")
        self.vm = vm
    }

    var body: some View {
        if vm.isLoading {
            Spacer()
            ActivityIndicator(isAnimating: $vm.isLoading)
            Spacer()
        } else {
            VStack {
                ScrollView {
                    Spacer().frame(height: 20)
                    LazyVStack(spacing: 0) {
                        ForEach(vm.books) { book in
                            BookCell(b: book) { action in
                                switch action {
                                case .select:
                                    vm.selectBook(book)
                                case .open:
                                    vm.openBook(book)
                                case .delete:
                                    vm.removeFromPlaylist(book)
                                }
                            }
                        }
                    }
                    Spacer().frame(height: 20)
                }
                .clipped()

                PlayerView(book: vm.selectedBook) { action in
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
                        vm.addBookmarkFormShown = true
                    }
                }
            }
        }
    }
}

enum BookCellAction {
    case select
    case open
    case delete
}

struct BookCell: View {
    @ObservedObject private var themeObservable = ThemeObservable.shared
    @ObservedObject private var book: Book
    @ObservedObject private var bookmarkColl: BookmarkColl
    @ObservedObject private var notifier = Notifier()

    @State var offset = CGSize.zero

    let title: String
    class Notifier: ObservableObject {
        @Published var subtitle: String = ""
    }

    let action: (BookCellAction) -> Void

    private var disposeBag: Set<AnyCancellable> = []

    init(b: Book, action: @escaping (BookCellAction) -> Void) {
        book = b
        bookmarkColl = b.bookmarkColl
        title = b.title
        self.action = action

        Publishers.CombineLatest(b.audioFileColl.$curFileIndex, b.audioFileColl.$curFileProgress)
            .map { index, progress in
                let time = DateTimeUtils.secToHHMMSS(b.totalDurationAt[index]! + progress)
                let totalDuration = DateTimeUtils.secToHHMMSS(b.totalDuration)
                return "\(index + 1)/\(b.audioFileColl.count), \(time)/\(totalDuration)"
            }.assign(to: \.subtitle, on: notifier)
            .store(in: &disposeBag)
    }

    var body: some View {
        GeometryReader { geometry in
            HStack(alignment: .center, spacing: 0) {
                Icon(name: book.isDamaged ? .damaged : book.playState == .playing ? .pause : .play, size: 12)
                    .allowsHitTesting(false)
                    .animation(.none)
                    .frame(width: Constants.size.actionBtnSize)

                VStack(alignment: .center, spacing: 4) {
                    Spacer()

                    Text(title)
                        .font(Constants.font.r15)
                        .minimumScaleFactor(12 / 15)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    HStack(alignment: .center, spacing: 2) {
                        Text(self.notifier.subtitle)
                            .font(Constants.font.r12)
                            .lineLimit(1)

                        Spacer().frame(width: 5)

                        if bookmarkColl.count > 0 {
                            Icon(name: .bookmarkSmall, size: 12)
                                .allowsHitTesting(false)

                            Text(bookmarkColl.count.description)
                                .font(Constants.font.r12)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    HSeparatorView(horizontalPadding: -Constants.size.actionBtnSize)
                }
                .frame(width: geometry.size.width > 2 * Constants.size.actionBtnSize ? geometry.size.width - 2 * Constants.size.actionBtnSize : 100)

                IconButton(name: .open, size: 14, color: book.playState == .stopped ? themeObservable.theme.text.color : themeObservable.theme.play.color) {
                    self.action(.open)
                }
                .accessibilityIdentifier("open-\(title)")
                .frame(width: Constants.size.actionBtnSize, height: Constants.size.bookListCellHeight)

                IconButton(name: .delete, size: 18, color: themeObservable.theme.deleteBtnIcon.color) {
                    self.action(.delete)
                }.frame(width: 70, height: Constants.size.bookListCellHeight)
                    .background(themeObservable.theme.deleteBtnBg.color)

                themeObservable.theme.deleteBtnBg.color.frame(width: -self.offset.width)
            }
            .background(themeObservable.theme.transparent.color)
            .foregroundColor(book.playState == .stopped ? themeObservable.theme.text.color : themeObservable.theme.play.color)
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
        }.frame(height: Constants.size.bookListCellHeight)
    }
}
