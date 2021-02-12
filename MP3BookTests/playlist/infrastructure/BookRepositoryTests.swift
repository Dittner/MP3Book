//
//  BookRepositoryTests.swift
//  MP3BookTests
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Combine
@testable import MP3Book
import XCTest

class BookRepositoryTests: XCTestCase {
    var book: Book!
    var storageURL: URL!

    override func setUpWithError() throws {
        let file1 = AudioFile(id: "file1", name: "file1", source: .documents, url: URLS.documentsURL, duration: 300, index: 0)
        let file2 = AudioFile(id: "file2", name: "file2", source: .documents, url: URLS.documentsURL, duration: 200, index: 1)
        book = Book(uid: UID(), folderPath: "documents/1984", title: "1984", files: [file1, file2])

        storageURL = URLS.libraryURL.appendingPathComponent("Test")
    }

    override func tearDownWithError() throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: storageURL.path) {
           try fileManager.removeItem(atPath: storageURL.path)
        }
    }
    
    func test() throws {
        try runBookSerializer()
        try updateBooks()
        try readBooks()
    }
    
    func runBookSerializer() throws {
        let audioFileSerializer = AudioFileSerializer()
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer)

        let serializedData = bookSerializer.serialize(book)
        let deserializedBook = try bookSerializer.deserialize(data: serializedData)

        XCTAssertTrue(equals(b1: book, b2: deserializedBook))
    }

    func updateBooks() throws {
        let audioFileSerializer = AudioFileSerializer()
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer)
        let bookRepository = try JSONBookRepository(serializer: bookSerializer, storeTo: storageURL)

        var isFirstRequestProcessed = false
        var isSecondRequestProcessed = false

        let subscription = bookRepository.value.sink { books in
            if !isFirstRequestProcessed {
                isFirstRequestProcessed = true
                XCTAssertEqual(books.count, 0)
            } else if !isSecondRequestProcessed {
                isSecondRequestProcessed = true
                XCTAssertEqual(books.count, 1)
                XCTAssertEqual(books[0].title, self.book.title)
            } else {
                XCTFail()
            }
        }

        XCTAssertTrue(isFirstRequestProcessed)

        try bookRepository.write([book])

        XCTAssertTrue(isSecondRequestProcessed)

        subscription.cancel()

        XCTAssertTrue(bookRepository.has(book.id))
        XCTAssertFalse(bookRepository.read(book.id)!.pendingToRemove)
    }

    func readBooks() throws {
        let audioFileSerializer = AudioFileSerializer()
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer)
        let bookRepository = try JSONBookRepository(serializer: bookSerializer, storeTo: storageURL)

        var isFirstRequestProcessed = false
        let subscription = bookRepository.value.sink { books in
            isFirstRequestProcessed = true
            if books.count == 1 {
                XCTAssertTrue(self.equals(b1: books[0], b2: self.book))
            } else {
                XCTFail()
            }
        }

        XCTAssertTrue(isFirstRequestProcessed)

        subscription.cancel()
        
        if let b = bookRepository.read(book.id) {
            XCTAssertFalse(b.pendingToRemove)
        } else {
            XCTFail()
        }
    }

    func equals(b1: Book, b2: Book) -> Bool {
        if b1.id != b2.id { return false }
        if b1.title != b2.title { return false }
        if b1.folderPath != b2.folderPath { return false }
        if b1.files.count != b2.files.count { return false }
        for (index, b1file) in b1.files.enumerated() {
            let b2file = b2.files[index]

            if b1file.id != b2file.id { return false }
            if b1file.name != b2file.name { return false }
            if b1file.source != b2file.source { return false }
            if b1file.url != b2file.url { return false }
            if b1file.duration != b2file.duration { return false }
            if b1file.index != b2file.index { return false }
        }

        return true
    }
}
