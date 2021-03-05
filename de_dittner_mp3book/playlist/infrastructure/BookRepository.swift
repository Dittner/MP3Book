//
//  BookRepository.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Combine
import Foundation

class JSONBookRepository: ObservableObject, IBookRepository {
    let value = CurrentValueSubject<[Book], Never>([])

    private let hash: [SUID: Book] = [:]

    func update(with books: [Book]) {
        value.send(books)
    }

    func has(bookId: SUID) -> Bool {
        return hash[bookId] != nil
    }

    func read(bookId: SUID) -> Book? {
        return hash[bookId]
    }
}
