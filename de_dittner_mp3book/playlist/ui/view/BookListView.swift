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

            if vm.playRateSelectorShown {
                PlayRateSelector(isShown: $vm.playRateSelectorShown, selectedRate: vm.playingBook?.rate ?? 1.0) { rate in
                    self.vm.updateRate(value: rate)
                }
            }
        }
    }
}

struct PlayRateSelector: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    let selectAction: (Float) -> Void
    let selectedRate: Float
    @Binding var isShown: Bool

    static let playRates: [Float] = [0.5, 0.6, 0.7, 0.8, 0.9, 1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0]

    init(isShown: Binding<Bool>, selectedRate: Float, selectAction: @escaping (Float) -> Void) {
        _isShown = isShown
        self.selectedRate = selectedRate
        self.selectAction = selectAction
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.1)
                .ignoresSafeArea()
                .onTapGesture {
                    isShown = false
                }

            VStack(alignment: .center, spacing: 0) {
                Spacer()

                VStack(alignment: .center, spacing: 0) {
                    Text("Tempo")
                        .font(Font.custom(.helveticaNeue, size: 15))
                        .frame(height: 30)

                    ForEach(PlayRateSelector.playRates, id: \.self) { value in
                        SeparatorView()
                        Text(value.description)
                            .font(Font.custom(selectedRate == value ? .helveticaNeueBold : .helveticaNeue, size: 15))
                            .frame(height: 30)
                            .onTapGesture {
                                self.selectAction(value)
                                self.isShown = false
                            }
                    }

                }.padding(.horizontal, 20)
                    .frame(width: 100)
                    .foregroundColor(themeObservable.theme.tint.color)
                    .lineLimit(1)

                    .background(themeObservable.theme.popupBg.color)
                    .cornerRadius(20)

                DownArrow()
                    .fill(themeObservable.theme.popupBg.color)
                    .frame(width: 25, height: 15)

                Spacer().frame(height: PlayerView.playerHeight - 70)
            }
        }
    }
}

struct PlaylistContent: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var vm: BookListVM

    init(vm: BookListVM) {
        print("PlaylistContent")
        self.vm = vm
    }

    var body: some View {
        if vm.isLoading {
            ActivityIndicator(isAnimating: $vm.isLoading)
        } else {
            VStack {
                ScrollView {
                    LazyVStack(alignment: .center, spacing: 1) {
                        ForEach(vm.books) { book in
                            BookCell(b: book) {
                                self.vm.selectBook(book)
                            }
                        }
                    }
                }
                .clipped()

                PlayerView(playingBook: vm.playingBook) { action in
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
                    }
                }
            }
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

    let selectAction: () -> Void

    private var disposeBag: Set<AnyCancellable> = []

    init(b: Book, selectAction: @escaping () -> Void) {
        book = b
        title = b.title
        self.selectAction = selectAction

        Publishers.CombineLatest(b.$curFileProgress, b.$curFileIndex)
            .map { curFileProgress, curFileIndex in
                let time = DateTimeUtils.secToHHMMSS(b.totalDurationAt[b.curFileIndex]! + curFileProgress)
                let totalDuration = DateTimeUtils.secToHHMMSS(b.totalDuration)
                return "\(curFileIndex + 1) / \(b.files.count), \(time)/\(totalDuration)"
            }
            .assign(to: \.subtitle, on: notifier)
            .store(in: &disposeBag)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image(book.playState == .playing ? "pause" : "play")
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

                SeparatorView(horizontalPadding: -50)

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
            selectAction()
        }
    }
}

enum PlayerAction {
    case updateProgress(value: Double)
    case play(b: Book)
    case pause
    case playNext
    case playPrev
    case selectRate
}

struct PlayerView: View {
    @ObservedObject private var themeObservable = ThemeObservable.shared
    @ObservedObject private var systemVolume = SystemVolume.shared
    @ObservedObject private var book: Book

    @ObservedObject private var notifier = Notifier()

    let action: (PlayerAction) -> Void
    let disabled: Bool
    static let playerHeight: CGFloat = 170

    class Notifier: ObservableObject {
        @Published var time: String = "0"
        @Published var title: String = ""
        @Published var duration: String = "0"
        @Published var progress: Double = 0
    }

    static let fakeBook = Book(uid: UID(), folderPath: "", title: "", files: [AudioFile(id: "0", name: "", source: .documents, path: "", duration: 0, index: 0, dispatcher: PlaylistDispatcher())], totalDuration: 0, dispatcher: PlaylistDispatcher())

    private var disposeBag: Set<AnyCancellable> = []

    init(playingBook: Book?, action: @escaping (PlayerAction) -> Void) {
        print("PlayerView init")
        if let b = playingBook {
            disabled = false
            book = b
        } else {
            disabled = true
            book = PlayerView.fakeBook
        }

        self.action = action
        let curBB = book

        book.$curFileProgress
            .map { $0.asDouble }
            .assign(to: \.progress, on: notifier)
            .store(in: &disposeBag)

        book.$curFile
            .map { $0.duration }
            .map { DateTimeUtils.secToHHMMSS($0) }
            .assign(to: \.duration, on: notifier)
            .store(in: &disposeBag)

        book.$curFileIndex
            .map { ($0 + 1).description + "/" + curBB.files.count.description }
            .assign(to: \.title, on: notifier)
            .store(in: &disposeBag)

        notifier.$progress
            .map { DateTimeUtils.secToHHMMSS(Int($0)) }
            .assign(to: \.time, on: notifier)
            .store(in: &disposeBag)
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(LinearGradient(gradient: Gradient(colors: themeObservable.theme.toolbarColors.reversed()), startPoint: .top, endPoint: .bottom))
                .cornerRadius(radius: 20, corners: [.topLeft, .topRight])
                .overlay(
                    VStack(alignment: .center, spacing: 2) {
                        HStack(alignment: .top, spacing: 0) {
                            Text(notifier.time)
                            Spacer()
                            Text(notifier.title)
                            Spacer()
                            Text(notifier.duration)
                        }
                        .font(Font.custom(.helveticaNeue, size: 13))
                        .lineLimit(1)

                        SliderView(progress: $notifier.progress, minValue: 0, maxValue: book.curFile.duration.asDouble, trackColor: themeObservable.theme.sliderTrack.color) { progress in
                            self.action(.updateProgress(value: progress))
                        }

                        Spacer().frame(height: 5)

                        HStack(alignment: .top, spacing: 0) {
                            HStack(alignment: .center, spacing: 2) {
                                Text(systemVolume.value.description + "%")
                                    .font(Font.custom(.helveticaNeue, size: 13))
                                    .lineLimit(1)

                                Image("volume")
                                    .renderingMode(.template)
                                    .allowsHitTesting(false)

                            }.frame(width: 50, height: 50, alignment: .leading)

                            Spacer()

                            VStack(alignment: .center, spacing: 2) {
                                TextButton(text: "-15s", textColor: themeObservable.theme.tint.color, font: Font.custom(.helveticaNeueBold, size: 15)) {
                                    if self.notifier.progress > 15 {
                                        self.action(.updateProgress(value: self.notifier.progress - 15))
                                    } else {
                                        self.action(.updateProgress(value: 0.001))
                                    }
                                }
                                .frame(width: 50, height: 50, alignment: .center)

                                IconButton(iconName: "playerBackward", iconColor: themeObservable.theme.tint.color) {
                                    self.action(.playPrev)
                                }
                                .frame(width: 50, height: 50, alignment: .center)
                            }

                            Spacer()

                            VStack(alignment: .center, spacing: 2) {
                                TextButton(text: "\(book.rate)x", textColor: themeObservable.theme.tint.color, font: Font.custom(.helveticaNeueBold, size: 15)) {
                                    self.action(.selectRate)
                                }
                                .frame(width: 50, height: 50, alignment: .center)

                                IconButton(iconName: book.playState == .playing ? "playerPause" : "playerPlay", iconColor: themeObservable.theme.tint.color) {
                                    self.action(book.playState == .playing ? .pause : .play(b: book))
                                }
                                .frame(width: 50, height: 50, alignment: .center)
                            }

                            Spacer()

                            VStack(alignment: .center, spacing: 2) {
                                TextButton(text: "+15s", textColor: themeObservable.theme.tint.color, font: Font.custom(.helveticaNeueBold, size: 15)) {
                                    if self.book.curFile.duration.asDouble - self.notifier.progress > 15 {
                                        self.action(.updateProgress(value: self.notifier.progress + 15))
                                    } else {
                                        self.action(.updateProgress(value: self.book.curFile.duration.asDouble))
                                    }
                                }
                                .frame(width: 50, height: 50, alignment: .center)

                                IconButton(iconName: "playerForward", iconColor: themeObservable.theme.tint.color) {
                                    self.action(.playNext)
                                }
                                .frame(width: 50, height: 50, alignment: .center)
                            }

                            Spacer()

                            VStack(alignment: .trailing, spacing: -10) {
                                IconButton(iconName: "addComment", iconColor: themeObservable.theme.tint.color) { }
                                    .frame(width: 50, height: 50, alignment: .center)

                                Text("4")
                                    .font(Font.custom(.helveticaNeue, size: 13))
                                    .lineLimit(1)
                                    .frame(width: 50, alignment: .center)

                            }.offset(x: 15)
                        }
                        .font(Font.custom(.helveticaNeue, size: 13))
                        .lineLimit(1)
                    }
                    .foregroundColor(themeObservable.theme.tint.color)
                    .padding()

                    .allowsHitTesting(!disabled)
                    // .opacity(disabled ? 0.8 : 1)
                )
        }.frame(height: PlayerView.playerHeight)
    }
}
