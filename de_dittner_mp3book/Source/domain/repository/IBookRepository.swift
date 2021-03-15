//
//  IBookRepository.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Foundation
import Combine

protocol IBookRepository {
    var subject: CurrentValueSubject<[Book], Never> { get }
    var isReady: Bool {get}
    func has(_ bookID: ID) -> Bool
    func read(_ bookID: ID) -> Book?
    func write(_ books: [Book]) throws
    func remove(_ bookID: ID)
}
