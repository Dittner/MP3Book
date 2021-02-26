//
//  PlayerView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 22.02.2021.
//

import Combine
import SwiftUI

enum PlayerAction {
    case updateProgress(value: Double)
    case play(b: Book)
    case pause
    case playNext
    case playPrev
    case selectRate
    case addBookmark
}

class PNotifier: ObservableObject {
    @Published var time: Int = 0
    @Published var duration: Int = 0
    @Published var progress: Double = 0.0
    @Published var bookmarksCount: Int = 0
    @Published var count: Int = 0
    @Published var index: Int = 0
}

struct PlayerView: View {
    @ObservedObject private var themeObservable = ThemeObservable.shared
    @ObservedObject private var systemVolume = SystemVolume.shared
    @ObservedObject var notifier = PNotifier()
    @ObservedObject var book: Book
    @State var progress: Double = 0.0

    let action: (PlayerAction) -> Void
    static let playerHeight: CGFloat = 170

    static let fakeBook = Book(uid: UID(), folderPath: "", title: "", files: [AudioFile(uid: 0, id: "0", name: "", source: .documents, path: "", duration: 0, index: 0, dispatcher: PlaylistDispatcher())], bookmarks: [], sortType: .none, dispatcher: PlaylistDispatcher())

    private var disposeBag: Set<AnyCancellable> = []

    init(book: Book?, action: @escaping (PlayerAction) -> Void) {
        print("PlayerView init")
        let b = book ?? PlayerView.fakeBook
        self.book = b
        self.action = action

        b.$coll
            .flatMap { $0.curFileIndexPublisher }
            .assign(to: \.index, on: notifier)
            .store(in: &disposeBag)

        b.$coll
            .flatMap { $0.countPublisher }
            .assign(to: \.count, on: notifier)
            .store(in: &disposeBag)

        b.$coll
            .flatMap { $0.curFilePublisher }
            .map { curFile in curFile?.duration ?? 0 }
            .assign(to: \.duration, on: notifier)
            .store(in: &disposeBag)

        b.bookmarkColl.$count
            .assign(to: \.bookmarksCount, on: notifier)
            .store(in: &disposeBag)

        b.$coll
            .flatMap { $0.curFileProgressPublisher }
            .map { progress in progress.asDouble }
            .assign(to: \.progress, on: notifier)
            .store(in: &disposeBag)

        b.$coll
            .flatMap { $0.curFileProgressPublisher }
            .assign(to: \.time, on: notifier)
            .store(in: &disposeBag)
    }
    
    func getTitle(playMode: PlayMode, index: Int, count:Int) -> String {
        if playMode == .audioFile {
            return (notifier.index + 1).description + "/" + notifier.count.description
        } else {
            return count == 0 ? "" : (notifier.index + 1).description + "/" + notifier.count.description
        }
    }

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            HStack(alignment: .top, spacing: 0) {
                Text(DateTimeUtils.secToHHMMSS(notifier.time))
                Spacer()
                Text(getTitle(playMode: book.playMode, index: notifier.index, count: notifier.count))
                
                if book.playMode == .bookmark {
                    Image("bookmarkSmall")
                        .renderingMode(.template)
                        .allowsHitTesting(false)
                        .offset(x: 2, y: 2)
                }
                Spacer()
                Text(DateTimeUtils.secToHHMMSS(notifier.duration))
            }
            .font(Font.custom(.helveticaNeue, size: 13))
            .lineLimit(1)

            SliderView(progress: $notifier.progress, minValue: 0, maxValue: notifier.duration.asDouble, trackColor: themeObservable.theme.sliderTrack.color) { progress in
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
                    TextButton(text: "\(String(format: "%.1f", book.rate))x", textColor: themeObservable.theme.tint.color, font: Font.custom(.helveticaNeueBold, size: 15)) {
                        withAnimation {
                            self.action(.selectRate)
                        }
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
                        guard let curFile = self.book.coll.curFile else { return }
                        if curFile.duration.asDouble - self.notifier.progress > 15 {
                            self.action(.updateProgress(value: self.notifier.progress + 15))
                        } else {
                            self.action(.updateProgress(value: curFile.duration.asDouble))
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
                    IconButton(iconName: "addBookmark", iconColor: themeObservable.theme.tint.color) {
                        withAnimation {
                            self.action(.addBookmark)
                        }
                    }
                    .frame(width: 50, height: 50, alignment: .center)

                    Text(notifier.bookmarksCount.description)
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
        .allowsHitTesting(self.notifier.duration != 0)
        .frame(height: PlayerView.playerHeight)
        .background(Rectangle()
            .fill(LinearGradient(gradient: Gradient(colors: themeObservable.theme.playerColors), startPoint: .top, endPoint: .bottom))
            .cornerRadius(radius: 20, corners: [.topLeft, .topRight]))
    }
}
