//
//  JSONBookRepository.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Combine
import Foundation

enum JSONBookRepositoryError: DetailedError {
    case createStorageDirFailed(details: String)
    case writeBookToDiscFailed(bookTitle: String, details: String)
    case readBooksFromDiscFailed(details: String)
    case jsonSerializationFailed(bookTitle: String, details: String)
    case jsonDeserializationFailed(url: String, details: String)
}

class JSONBookRepository: IBookRepository {
    let value = CurrentValueSubject<[Book], Never>([])

    private let url: URL
    private var hash: [ID: Book] = [:]
    private let serializer: IBookSerializer

    init(serializer: IBookSerializer, storeTo: URL) throws {
        logInfo(msg: "JSONBookRepository init, url: \(storeTo)")
        self.serializer = serializer
        url = storeTo.appendingPathComponent("book")

        try createStorageIfNeeded()
        try readBooksFromDisc()
    }

    private func createStorageIfNeeded() throws {
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw JSONBookRepositoryError.createStorageDirFailed(details: error.localizedDescription)
            }
        }
    }

    private func readBooksFromDisc() throws {
        do {
            var books = [Book]()
            let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil).filter { $0.pathExtension == "m3b" }
            for fileURL in urls {
                let data = try Data(contentsOf: fileURL)
                let dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                let b = try serializer.deserialize(data: dict)
                hash[b.id] = b
                books.append(b)
            }
            if books.count > 0 {
                value.send(books)
            }
        } catch {
            throw JSONBookRepositoryError.readBooksFromDiscFailed(details: error.localizedDescription)
        }
    }

    func has(_ bookID: ID) -> Bool {
        return hash[bookID] != nil
    }

    func read(_ bookID: ID) -> Book? {
        return hash[bookID]
    }

    func write(_ books: [Book]) throws {
        for b in books {
            let fileUrl = url.appendingPathComponent(b.uid.description + ".m3b")
            let dict = serializer.serialize(b)

            do {
                let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
                do {
                    try data.write(to: fileUrl)
                    hash[b.id] = b
                    value.value.append(b)
                    // value.send(value.value.append(b))
                } catch {
                    throw JSONBookRepositoryError.writeBookToDiscFailed(bookTitle: b.title, details: error.localizedDescription)
                }
            } catch {
                throw JSONBookRepositoryError.jsonSerializationFailed(bookTitle: b.title, details: error.localizedDescription)
            }
        }
    }
}
