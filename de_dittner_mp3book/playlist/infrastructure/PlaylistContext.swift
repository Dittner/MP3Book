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
    let dispatcher: PlaylistDispatcher

    init() {
        print("PlaylistContext initialized")
        dispatcher = PlaylistDispatcher()
        
        let storageURL = URLS.libraryURL.appendingPathComponent("Storage/book")
        let audioFileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)
        
        bookRepository = try! JSONBookRepository(serializer: bookSerializer, dispatcher: dispatcher, storeTo: storageURL)
        addBooksToPlaylistDomainService = AddBooksToPlaylistDomainService(repo: bookRepository)
    }
}
