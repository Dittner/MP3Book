//
//  PlaylistBooksToHashMapper.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation

class PlaylistBooksToHashMapper {
    func convert(_ books: [Book]) -> [ID: Bool] {
        var res: [ID: Bool] = [:]
        for book in books {
            res[book.id] = true
        }
        return res
    }
}
