//
//  LibraryContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class PlaylistContext {
    static var shared: PlaylistContext = PlaylistContext()
    let bookRepository: IBookRepository
    let addBooksToPlaylistDomainService: AddBooksToPlaylistDomainService
    let playerAppService: PlayerAppService
    
    let dispatcher: PlaylistDispatcher
    let playlistBooksPort: OutputPort<Book>

    init() {
        print("PlaylistContext initialized")
        dispatcher = PlaylistDispatcher()

        let storageURL = URLS.libraryURL.appendingPathComponent("Storage/book")
        let audioFileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)

        bookRepository = try! JSONBookRepository(serializer: bookSerializer, dispatcher: dispatcher, storeTo: storageURL)
        addBooksToPlaylistDomainService = AddBooksToPlaylistDomainService(repo: bookRepository)
        
        playerAppService = PlayerAppService(api: MediaAPI())
        playlistBooksPort = OutputPort<Book>()

        listenToPlaylistBooks()
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func listenToPlaylistBooks() {
        bookRepository.subject
            .dropFirst()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { books in
                self.playlistBooksPort.write(books.filter { $0.addedToPlaylist })
            }
            .store(in: &disposeBag)

        dispatcher.subject
            .dropFirst()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { event in
                switch event {
                case .bookToPlaylistAdded, .bookFromPlaylistRemoved:
                    self.playlistBooksPort.write(self.bookRepository.subject.value.filter { $0.addedToPlaylist })
                default:
                    break
                }
            }
            .store(in: &disposeBag)
    }
}
