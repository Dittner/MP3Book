//
//  UITestBooks.swift
//  MP3BookUITests
//
//  Created by Alexander Dittner on 17.03.2021.
//

import Foundation
enum UITestBook: String {
    case orwell = "George Orwell – 1984"
    case freud = "Sigmund Freud – Die Zukunft einer Illusion"
    case dostoevsky = "Достоевский – Записки из подполья"

    static func allBooks() -> [UITestBook] {
        return [.orwell, .freud, .dostoevsky]
    }
}
