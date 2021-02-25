//
//  AddBooksToPlaylistDomainService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation
class AddBooksToPlaylistDomainService {
    let repo: IBookRepository

    init(repo: IBookRepository) {
        self.repo = repo
    }

    func add(_ books: [Book], from: AudioFileSource) throws {
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
