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

    init(serializer: IBookSerializer, dispatcher: PlaylistDispatcher, storeTo: URL) {
        logInfo(msg: "JSONBookRepository init, url: \(storeTo)")
        self.serializer = serializer

        self.dispatcher = dispatcher
        url = storeTo

        createStorageIfNeeded()
        readBooksFromDisk()
        subscribeToDispatcher()
    }

    private func createStorageIfNeeded() {
        if !FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.createDirectory(atPath: url.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                logErr(msg: JSONBookRepositoryError.createStorageDirFailed(details: error.localizedDescription).localizedDescription)
            }
        }
    }

    private func readBooksFromDisk() {
        Async.background {
            var books = [Book]()
            do {
                let urls = try FileManager.default.contentsOfDirectory(at: self.url, includingPropertiesForKeys: nil).filter { $0.pathExtension == "m3b" }

                logInfo(msg: "Books count on disc: \(urls.count)")

                for fileURL in urls {
                    do {
                        let data = try Data(contentsOf: fileURL)
                        let b = try self.serializer.deserialize(data: data)
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
                        logErr(msg: "Failed to deserialize a book, url: \(fileURL), details: \(error.localizedDescription)")
                        try self.destroyBook(storeURL: fileURL)
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

    private let iPodService = IPodAppService()
    private func bookSourceExists(_ b: Book) -> Bool {
        if let url = b.getURL() {
            if b.source == .documents {
                return url.fileExists()
            } else if let id = b.playlistID, iPodService.playlistExists(persistentID: id) {
                return true
            }
        }
        return false
    }

    private func destroyBook(_ b: Book) throws {
        let storeURL = getBookStoreURL(b)
        if FileManager.default.fileExists(atPath: storeURL.path) {
            do {
                try FileManager.default.removeItem(atPath: storeURL.path)
                b.destroyed = true
                logInfo(msg: "Book «\(b.title)» has been destroyed")
            } catch {
                throw JSONBookRepositoryError.removeBookFromDiscFailed(details: error.localizedDescription)
            }
        }
    }

    private func destroyBook(storeURL: URL) throws {
        if FileManager.default.fileExists(atPath: storeURL.path) {
            do {
                try FileManager.default.removeItem(atPath: storeURL.path)
            } catch {
                throw JSONBookRepositoryError.removeBookFromDiscFailed(details: error.localizedDescription)
            }
        }
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func subscribeToDispatcher() {
        dispatcher.subject
            .sink { event in
                switch event {
                case let .audioFileStateChanged(file):
                    if self.has(file.book.id) {
                        self.pendingBooksToStore.append(file.book.id)
                        self.storeChanges()
                    }
                case let .bookStateChanged(book):
                    if self.has(book.id) {
                        self.pendingBooksToStore.append(book.id)
                        self.storeChanges()
                    }
                default:
                    break
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

    func remove(_ bookID: ID) {
        guard let book = read(bookID) else { return }
        try? destroyBook(book)
        hash[book.id] = nil

        var books = subject.value
        if let bookIndex = books.firstIndex(of: book) {
            books.remove(at: bookIndex)
        }

        subject.send(books)
    }

    func write(_ books: [Book]) {
        var newBooks: [Book] = []
        for b in books {
            if !has(b.id) {
                hash[b.id] = b
                newBooks.append(b)
                pendingBooksToStore.append(b.id)
                storeChanges()
            }
        }

        subject.send(newBooks.count > 0 ? subject.value + newBooks : subject.value)
    }

    private var pendingBooksToStore: [ID] = []
    func storeChanges() {
        Async.after(milliseconds: 1000) {
            for bookID in self.pendingBooksToStore.removeDuplicates() {
                if let book = self.read(bookID) {
                    self.store(book)
                }
            }
            self.pendingBooksToStore = []
            self.dispatcher.subject.send(.repositoryStoreComplete(repo: self))
        }
    }

    private func store(_ b: Book) {
        DispatchQueue.global(qos: .utility).sync {
            do {
                let fileUrl = self.getBookStoreURL(b)
                let data = try self.serializer.serialize(b)
                do {
                    try data.write(to: fileUrl)
                } catch {
                    logErr(msg: "Failed to write book «\(b.title)» on disc, details:  \(error.localizedDescription)")
                }
            } catch {
                logErr(msg: "Failed to serialize book «\(b.title)», details:  \(error.localizedDescription)")
            }
        }
    }
}
