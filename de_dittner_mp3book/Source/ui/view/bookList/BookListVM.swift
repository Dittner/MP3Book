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
    @Published var isLoading = true
    @Published var books: [Book] = []
    @Published var playRateSelectorShown: Bool = false
    @Published var addBookmarkFormShown: Bool = false
    @Published var selectedBook: Book?

    private let player: PlayerAppService
    private var disposeBag: Set<AnyCancellable> = []
    private var playSuspending: Bool = false
    private let context: MP3BookContextProtocol

    init(context: MP3BookContextProtocol) {
        logInfo(msg: "BookListVM init")
        self.context = context
        player = context.app.playerService

        super.init(id: .bookList, navigator: context.ui.navigator)

        waitWhenRepoIsReady()

        context.domain.bookRepository.subject
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { books in
                self.books = books.filter { $0.addedToPlaylist }.sorted(by: { $0.title < $1.title })
                logInfo(msg: "BookListVM received books: \(self.books.count)/\(books.count)")
                self.setupLastPlayedBook()
            }.store(in: &disposeBag)

        player.$book
            .removeDuplicates()
            .sink { book in
                self.selectedBook = book
            }.store(in: &disposeBag)

        $addBookmarkFormShown.sink { isModalViewShown in
            guard let b = self.selectedBook else { return }
            if isModalViewShown && b.playState == .playing {
                self.playSuspending = true
                self.pause()
            } else if !isModalViewShown && self.playSuspending {
                self.play(b)
                self.playSuspending = false
            }
        }.store(in: &disposeBag)
    }

    private func waitWhenRepoIsReady() {
        if context.domain.bookRepository.isReady {
            isLoading = false
        } else {
            context.domain.dispatcher.subject
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

    var firstLaunch: Bool = true
    private func setupLastPlayedBook() {
        guard let bookID = UserDefaults.standard.object(forKey: Constants.keys.lastPlayedBookID) as? ID else { return }
        if let book = books.first(where: { $0.id == bookID }) {
            if firstLaunch {
                firstLaunch = false
                selectBook(book)
                pause()
            } else {
                selectedBook = book
            }
        } else {
            selectedBook = nil
        }
    }

    func addBooks() {
        pause()
        navigator.navigate(to: .library)
    }

    func openBook(_ b: Book) {
        context.ui.viewModels.fileListVM.selectedBook = b
        navigator.navigate(to: .audioFileList)
    }

    func addBookmark(time: Int, comment: String, file: AudioFile) {
        selectedBook?.bookmarkColl.addMark(Bookmark(uid: UID(), file: file, time: time, comment: comment))
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
        #if UITESTING
            b.playState = .playing
            selectedBook = b
        #else
            if b.playState == .playing {
                player.pause()
            } else {
                player.play(b)
            }
            UserDefaults.standard.set(b.id, forKey: Constants.keys.lastPlayedBookID)
        #endif
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
