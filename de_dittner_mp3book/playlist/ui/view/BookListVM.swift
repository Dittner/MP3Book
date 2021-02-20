//
//  LibraryVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation
import MediaPlayer

class BookListVM: ViewModel, ObservableObject {
    static var shared: BookListVM = BookListVM(id: .bookList)

    @Published var isLoading = false
    @Published var books: [Book] = []
    @Published var playingBook: Book? = nil
    @Published var playRateSelectorShown: Bool = false
    @Published var addBookmarkFormShown: Bool = false

    private let context: PlaylistContext
    private let player: PlayerAppService
    private var disposeBag: Set<AnyCancellable> = []

    override init(id: ScreenID) {
        logInfo(msg: "BookListVM init")
        context = PlaylistContext.shared
        player = context.playerAppService

        super.init(id: id)

        context.bookRepository.subject
            .sink { books in
                self.books = books.filter { $0.addedToPlaylist }.sorted(by: { $0.title < $1.title })

            }.store(in: &disposeBag)

        $playRateSelectorShown.sink { value in
            print("playRateSelectorShown = \(value)")
        }.store(in: &disposeBag)
    }

    func addBooks() {
        navigator.navigate(to: .library)
    }

    func openBook(_ b: Book) {
        AudioFileListVM.shared.selectedBook = b
        navigator.navigate(to: .audioFileList)
    }

    func addBookmark(time: Int, comment: String) {
        playingBook?.curFile.addMark(Bookmark(time: time, comment: comment))
    }

    func removeFromPlaylist(_ b: Book) {
        b.addedToPlaylist = false
        books = books.filter { $0.addedToPlaylist }
    }

    // -------------------------------------
    //
    //   PLAYER
    //
    // -------------------------------------

    func selectBook(_ b: Book) {
        if b.playState == .playing {
            player.pause()
        } else {
            if playingBook == nil || playingBook!.id != b.id {
                playingBook = b
            }
            player.play(b)
        }
    }

    func updateProgress(value: Double) {
        player.updatePosition(value: value)
    }

    func play(_ b: Book) {
        playingBook = b
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
