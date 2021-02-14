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
    case removeBookFromDiscFailed(details: String)
    case jsonSerializationFailed(bookTitle: String, details: String)
    case jsonDeserializationFailed(url: String, details: String)
}

class JSONBookRepository: IBookRepository {
    let subject = CurrentValueSubject<[Book], Never>([])

    private let url: URL
    private var hash: [ID: Book] = [:]
    private let serializer: IBookSerializer
    private let dispatcher: PlaylistDispatcher
    private(set) var isReady: Bool = false

    init(serializer: IBookSerializer, dispatcher: PlaylistDispatcher, storeTo: URL) throws {
        logInfo(msg: "JSONBookRepository init, url: \(storeTo)")
        self.serializer = serializer
        self.dispatcher = dispatcher
        url = storeTo

        try createStorageIfNeeded()
        readBooksFromDisc()
        subscribeToDispatcher()
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

    private func readBooksFromDisc() {
        Async.background {
            var books = [Book]()
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: self.url, includingPropertiesForKeys: nil).filter { $0.pathExtension == "m3b" }

                for fileURL in urls {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        let dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                        let b = try self.serializer.deserialize(data: dict)
                        if self.bookSourceExists(b) {
                            self.hash[b.id] = b
                            books.append(b)
                        } else {
                            do {
                                try self.destroyBook(b)
                            } catch {
                                logErr(msg: "Failed to destroy book «\(b.title)», details: \(error.localizedDescription)")
                            }
                        }
                    } catch {
                        logErr(msg: "Failed to serialize book, url: \(fileURL), details: \(error.localizedDescription)")
                    }
                }
            } catch {
                logErr(msg: "Failed to read urls, details: \(error.localizedDescription)")
            }

            Async.main {
                if books.count > 0 {
                    self.subject.send(books)
                }
                self.isReady = true
                self.dispatcher.subject.send(.repositoryIsReady(repo: self))
            }
        }
    }

    private func bookSourceExists(_ b: Book) -> Bool {
        return FileManager.default.fileExists(atPath: URLS.documentsURL.appendingPathComponent(b.folderPath).path)
    }

    private func destroyBook(_ b: Book) throws {
        let storeURL = getBookStoreURL(b)
        if FileManager.default.fileExists(atPath: storeURL.path) {
            do {
                try FileManager.default.removeItem(atPath: storeURL.path)
                logInfo(msg: "Book «\(b.title)» has been destroyed")
            } catch {
                throw JSONBookRepositoryError.removeBookFromDiscFailed(details: error.localizedDescription)
            }
        }
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func subscribeToDispatcher() {
        dispatcher.subject
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { event in
                do {
                    switch event {
                    case let .audioFileStateChanged(file):
                        if self.has(file.book.id) {
                            try self.store(file.book)
                        }
                    case let .bookStateChanged(book):
                        if self.has(book.id) {
                            try self.store(book)
                        }
                    default:
                        break
                    }
                } catch {
                    logErr(msg: error.localizedDescription)
                }
            }
            .store(in: &disposeBag)
    }

    func getBookStoreURL(_ b: Book) -> URL {
        return url.appendingPathComponent(b.uid.description + ".m3b")
    }

    func has(_ bookID: ID) -> Bool {
        return hash[bookID] != nil
    }

    func read(_ bookID: ID) -> Book? {
        return hash[bookID]
    }

    func write(_ books: [Book]) throws {
        var newBooks: [Book] = []
        for b in books {
            if !has(b.id) {
                try store(b)
                hash[b.id] = b
                newBooks.append(b)
            }
        }

        if newBooks.count > 0 {
            subject.send(subject.value + newBooks)
        }
    }

    private func store(_ b: Book) throws {
        do {
            let fileUrl = getBookStoreURL(b)
            let dict = serializer.serialize(b)
            let data = try JSONSerialization.data(withJSONObject: dict, options: .fragmentsAllowed)
            do {
                try data.write(to: fileUrl)

            } catch {
                throw JSONBookRepositoryError.writeBookToDiscFailed(bookTitle: b.title, details: error.localizedDescription)
            }
        } catch {
            throw JSONBookRepositoryError.jsonSerializationFailed(bookTitle: b.title, details: error.localizedDescription)
        }
    }
}