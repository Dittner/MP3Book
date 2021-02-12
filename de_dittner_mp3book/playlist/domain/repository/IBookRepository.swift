//
//  IBookRepository.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Foundation
import Combine

protocol IBookRepository {
    var value: CurrentValueSubject<[Book], Never> { get }
    func has(_ bookID: ID) -> Bool
    func read(_ bookID: ID) -> Book?
    func write(_ books: [Book]) throws
}
