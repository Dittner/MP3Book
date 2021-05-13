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
    @EnvironmentObject var themeManager: ThemeManager
    @EnvironmentObject var systemVolume: SystemVolume
    @ObservedObject var notifier = PNotifier()
    @ObservedObject var book: Book
    @State var progress: Double = 0.0

    let action: (PlayerAction) -> Void

    static let fakeBook = Book(uid: UID(), folderPath: "", title: "", files: [], bookmarks: [], sortType: .none, dispatcher: PlaylistDispatcher())

    private var disposeBag: Set<AnyCancellable> = []

    init(book: Book?, action: @escaping (PlayerAction) -> Void) {
        print("PlayerView init with book: \(book != nil)")
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

    func getTitle(index: Int, count: Int) -> String {
        return count == 0 ? "" : (notifier.index + 1).description + "/" + notifier.count.description
    }

    var body: some View {
        VStack(alignment: .center, spacing: 5) {
            HStack(alignment: .top, spacing: 0) {
                Text(DateTimeUtils.secToHHMMSS(notifier.time))
                    .font(Constants.font.r12)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(getTitle(index: notifier.index, count: notifier.count))
                    .font(Constants.font.r12)
                    .layoutPriority(1)

                if book.playMode == .bookmark {
                    Icon(name: .bookmarkSmall, size: 12)
                        .allowsHitTesting(false)
                        .offset(x: 2, y: 2)
                }
                Text(DateTimeUtils.secToHHMMSS(notifier.duration))
                    .font(Constants.font.r12)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .lineLimit(1)

            SliderView(progress: $notifier.progress, minValue: 0, maxValue: notifier.duration.asDouble, trackColor: themeManager.theme.sliderTrack.color) { progress in
                self.action(.updateProgress(value: progress))
            }

            Spacer().frame(height: 5)

            HStack(alignment: .top, spacing: 0) {
                HStack(alignment: .center, spacing: 2) {
                    Text(systemVolume.value.description + "%")
                        .font(Constants.font.r11)
                        .lineLimit(1)

                    Icon(name: .volume, size: 12)
                        .allowsHitTesting(false)

                }.frame(width: 50, height: 50, alignment: .leading)

                Spacer()

                VStack(alignment: .center, spacing: 2) {
                    TextButton(text: "-15s", textColor: themeManager.theme.tint.color, font: Constants.font.b14) {
                        if self.notifier.progress > 15 {
                            self.action(.updateProgress(value: self.notifier.progress - 15))
                        } else {
                            self.action(.updateProgress(value: 0.001))
                        }
                    }
                    .frame(width: 50, height: 50, alignment: .center)

                    IconButton(name: .playerBackward, size: 11, color: themeManager.theme.tint.color) {
                        self.action(.playPrev)
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                }

                Spacer()

                VStack(alignment: .center, spacing: 2) {
                    TextButton(text: "\(String(format: "%.1f", book.rate))x", textColor: themeManager.theme.tint.color, font: Constants.font.b14) {
                        withAnimation {
                            self.action(.selectRate)
                        }
                    }
                    .frame(width: 50, height: 50, alignment: .center)

                    IconButton(name: book.playState == .playing ? .playerPause : .playerPlay, size: 17, color: themeManager.theme.tint.color) {
                        self.action(book.playState == .playing ? .pause : .play(b: book))
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                }

                Spacer()

                VStack(alignment: .center, spacing: 2) {
                    TextButton(text: "+15s", textColor: themeManager.theme.tint.color, font: Constants.font.b14) {
                        guard let curFile = self.book.coll.curFile else { return }
                        if curFile.duration.asDouble - self.notifier.progress > 15 {
                            self.action(.updateProgress(value: self.notifier.progress + 15))
                        } else {
                            self.action(.updateProgress(value: curFile.duration.asDouble))
                        }
                    }
                    .frame(width: 50, height: 50, alignment: .center)

                    IconButton(name: .playerForward, size: 11, color: themeManager.theme.tint.color) {
                        self.action(.playNext)
                    }
                    .frame(width: 50, height: 50, alignment: .center)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: -10) {
                    IconButton(name: .addBookmark, size: 22, color: themeManager.theme.tint.color) {
                        withAnimation {
                            self.action(.addBookmark)
                        }
                    }
                    .frame(width: 50, height: 50, alignment: .center)

                    Text(notifier.bookmarksCount.description)
                        .font(Constants.font.r11)
                        .lineLimit(1)
                        .frame(width: 50, alignment: .center)

                }.offset(x: 16)
            }
            .lineLimit(1)
        }
        .foregroundColor(themeManager.theme.tint.color)
        .padding()
        .allowsHitTesting(self.notifier.duration != 0)
        .frame(height: Constants.size.playerHeight)
        .background(Rectangle()
            .fill(LinearGradient(gradient: Gradient(colors: themeManager.theme.playerColors), startPoint: .top, endPoint: .bottom))
            .cornerRadius(radius: 20, corners: [.topLeft, .topRight]))
    }
}
