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
    let dispatcher: PlaylistDomainEventDispatcher

    init() {
        print("PlaylistContext initialized")

        let storageURL = URLS.libraryURL.appendingPathComponent("Storage/book")
        let audioFileSerializer = AudioFileSerializer()
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer)

        dispatcher = PlaylistDomainEventDispatcher.shared
        bookRepository = try! JSONBookRepository(serializer: bookSerializer, storeTo: storageURL)
        addBooksToPlaylistDomainService = AddBooksToPlaylistDomainService(repo: bookRepository)
    }
}
