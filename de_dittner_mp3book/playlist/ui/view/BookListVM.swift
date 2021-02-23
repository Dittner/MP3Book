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

    @Published var isLoading = true
    @Published var books: [Book] = []
    @Published var playRateSelectorShown: Bool = false
    @Published var addBookmarkFormShown: Bool = false
    @Published var selectedBook: Book?

    private let context: PlaylistContext
    private let player: PlayerAppService
    private var disposeBag: Set<AnyCancellable> = []

    override init(id: ScreenID) {
        logInfo(msg: "BookListVM init")
        context = PlaylistContext.shared
        player = context.playerAppService

        super.init(id: id)
        
        waitWhenRepoIsReady()

        context.bookRepository.subject
            .sink { books in
                self.books = books.filter { $0.addedToPlaylist }.sorted(by: { $0.title < $1.title })
                self.setupLastPlayedBook()
                self.isLoading = false
            }.store(in: &disposeBag)
        
        player.$book
            .removeDuplicates()
            .sink { book in
                self.selectedBook = book
            }.store(in: &disposeBag)

        $playRateSelectorShown.sink { value in
            print("playRateSelectorShown = \(value)")
        }.store(in: &disposeBag)
    }
    
    private func waitWhenRepoIsReady() {
        if context.bookRepository.isReady {
            self.isLoading = false
        } else {
            context.dispatcher.subject
                .sink { event in
                    switch event {
                    case .repositoryIsReady:
                        self.isLoading = false
                    default:
                        break
                    }
                }.store(in: &disposeBag)
        }
    }
    
    private func setupLastPlayedBook() {
        guard let bookID = UserDefaults.standard.object(forKey: "lastPlayedBookID") as? ID else {return}
        if let book = context.bookRepository.read(bookID) {
            selectBook(book)
            pause()
        }
    }

    func addBooks() {
        navigator.navigate(to: .library)
    }

    func openBook(_ b: Book) {
        AudioFileListVM.shared.selectedBook = b
        navigator.navigate(to: .audioFileList)
    }

    func addBookmark(time: Int, comment: String, file: AudioFile) {
        player.book?.bookmarkColl.addMark(Bookmark(uid: UID(), file: file, time: time, comment: comment))
    }

    func removeFromPlaylist(_ b: Book) {
        b.addedToPlaylist = false
        if selectedBook == b {
            player.pause()
            b.playState = .stopped
            selectedBook = nil
        }
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
            player.play(b)
        }
        UserDefaults.standard.set(b.id, forKey: "lastPlayedBookID")
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
