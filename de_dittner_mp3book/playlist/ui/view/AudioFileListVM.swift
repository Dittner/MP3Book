//
//  LibraryVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation
import MediaPlayer

class AudioFileListVM: ViewModel, ObservableObject {
    static var shared: AudioFileListVM = AudioFileListVM(id: .audioFileList)

    @Published var isLoading = false
    @Published var files: [AudioFile] = []
    @Published var selectedBook: Book?
    @Published var playRateSelectorShown: Bool = false
    @Published var addBookmarkFormShown: Bool = false

    private let context: PlaylistContext
    let player: PlayerAppService
    private var disposeBag: Set<AnyCancellable> = []

    override init(id: ScreenID) {
        logInfo(msg: "AudioFileListVM init")
        context = PlaylistContext.shared
        player = context.playerAppService

        super.init(id: id)

        $selectedBook
            .compactMap { $0 }
            .sink { book in
                self.files = book.files

            }.store(in: &disposeBag)

        $playRateSelectorShown.sink { value in
            print("playRateSelectorShown = \(value)")
        }.store(in: &disposeBag)
    }

    func goBack() {
        navigator.goBack(to: .bookList)
    }

    func addBookmark(time: Int, comment: String) {
        player.book?.curFile.addMark(Bookmark(time: time, comment: comment))
    }

    func resortFiles() {
        if let b = selectedBook {
            pause()
            b.sort(b.sortType == .none ? .title : .none)
            files = b.files
        }
    }

    // -------------------------------------
    //
    //   PLAYER
    //
    // -------------------------------------

    func playFile(_ f: AudioFile) {
        guard let b = f.book else { return }

        if b.playState == .playing, b.curFileIndex == f.index {
            player.pause()
        } else {
            b.curFileIndex = f.index
            player.play(b)
        }
    }

    func updateProgress(value: Double) {
        player.updatePosition(value: value)
    }

    func play(_ b: Book) {
        player.play(b)
    }

    func pause() {
        player.pause()
    }

    func playNext() {
        player.playNext()
    }

    func playPrev() {
        player.playPrev()
    }

    func updateRate(value: Float) {
        player.updateRate(value: value)
    }
}
