//
//  AddBooksToPlaylistDomainService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation
class BookFactory {
    let repo: IBookRepository
    let folderToBook: FolderToBookMapperProtocol
    let playlistToBook: PlaylistToBookMapperProtocol

    init(repo: IBookRepository, folderToBook: FolderToBookMapperProtocol, playlistToBook: PlaylistToBookMapperProtocol) {
        self.repo = repo
        self.folderToBook = folderToBook
        self.playlistToBook = playlistToBook
    }

    func create(from folders: [Folder]) {
        let books = folderToBook.convert(from: folders)
        do {
            try store(books, from: .documents)
        } catch {
            logErr(msg: error.localizedDescription)
        }
    }

    func create(from playlists: [Playlist]) {
        let books = playlistToBook.convert(from: playlists)
        do {
            try store(books, from: .iPodLibrary)
        } catch {
            logErr(msg: error.localizedDescription)
        }
    }

    private func store(_ books: [Book], from: AudioFileSource) throws {
        updateBooks(newBooks: books, curBooks: repo.subject.value.filter { $0.source == from })
        try repo.write(books)
    }

    private func updateBooks(newBooks: [Book], curBooks: [Book]) {
        var newBooksHash: [ID: Book] = [:]
        var curBooksHash: [ID: Book] = [:]
        for b in curBooks {
            curBooksHash[b.id] = b
        }

        for b in newBooks {
            newBooksHash[b.id] = b
            if let b = curBooksHash[b.id] {
                b.addedToPlaylist = true
            }
        }

        for b in curBooks {
            if newBooksHash[b.id] == nil && b.addedToPlaylist {
                b.addedToPlaylist = false
            }
        }
    }
}
