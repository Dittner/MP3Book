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
    let destFolderName: String = "Test"
    let srcFileName: String = "test.mp3"

    var realFolder: Folder!
    var fakeFolder: Folder!
    var fakeBook: Book!
    var storageURL: URL!

    override func setUpWithError() throws {
        storageURL = URLS.libraryURL.appendingPathComponent("Test/book")
        try copyTestFilesToDocuments()
    }

    func copyTestFilesToDocuments() throws {
        try removeTestStorage()
        try removeTestFiles()
        
        let destDemoFolderURL = URLS.documentsURL.appendingPathComponent(destFolderName)
        let service = DemoFileAppService()
        try service.copyDemoFile(srcFileName: srcFileName, to: destDemoFolderURL)

        let file = FolderFile(filePath: destFolderName + "/" + srcFileName, name: srcFileName, duration: 60)
        realFolder = Folder(folderPath: destFolderName, title: destFolderName, parentFolderName: nil, totalDuration: 60, files: [file], depth: 0)
        fakeFolder = Folder(folderPath: "fakeFolder", title: "NoName", parentFolderName: nil, totalDuration: 60, files: [file], depth: 0)
    }

    


    func removeTestStorage() throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: storageURL.path) {
            try fileManager.removeItem(atPath: storageURL.path)
        }
    }

    func removeTestFiles() throws {
        let destDemoFolderURL = URLS.documentsURL.appendingPathComponent(destFolderName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destDemoFolderURL.path) {
            try fileManager.removeItem(atPath: destDemoFolderURL.path)
            print("Demo folder has been removed")
        } else {
            print("Demo folder does not exist")
        }
    }

    func test() throws {
        try convertFoldersAndAddBooksToRepo()
        try readBooksFromRepo()
    }

    func convertFoldersAndAddBooksToRepo() throws {
        let dispatcher = PlaylistDispatcher()
        let audioFileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)
        let bookRepository = try JSONBookRepository(serializer: bookSerializer, dispatcher: dispatcher, storeTo: storageURL)
        let addBooksToPlaylistDomainService = AddBooksToPlaylistDomainService(repo: bookRepository)
        let foldersToBooksMapper = FolderToMP3BookMapper(repo: bookRepository, dispatcher: dispatcher)
        
        waitWhenRepoIsReady(repo: bookRepository, dispatcher: dispatcher)

        var isFirstRequestProcessed = false
        var isSecondRequestProcessed = false
        var isThirdRequestProcessed = false

        let subscription = bookRepository.subject.sink { books in
            if !isFirstRequestProcessed {
                isFirstRequestProcessed = true
                XCTAssertEqual(books.count, 0)
            } else if !isSecondRequestProcessed {
                isSecondRequestProcessed = true
                XCTAssertEqual(books.count, 1)
                XCTAssertEqual(books[0].title, self.realFolder.title)
            } else if !isThirdRequestProcessed {
                isThirdRequestProcessed = true
                XCTAssertEqual(books.count, 2)
                XCTAssertEqual(books[1].title, self.fakeFolder.title)

            } else {
                XCTFail()
            }
        }

        XCTAssertTrue(isFirstRequestProcessed)

        let realBooks = foldersToBooksMapper.convert(from: [realFolder])
        try addBooksToPlaylistDomainService.add(realBooks, from: .documents)

        XCTAssertTrue(isSecondRequestProcessed)

        let fakeBooks = foldersToBooksMapper.convert(from: [fakeFolder])
        fakeBook = fakeBooks[0]
        try addBooksToPlaylistDomainService.add(fakeBooks, from: .documents)

        XCTAssertTrue(isThirdRequestProcessed)

        XCTAssertTrue(bookRepository.has(realFolder.id))
        XCTAssertTrue(bookRepository.has(fakeFolder.id))
        XCTAssertFalse(bookRepository.read(realFolder.id)!.addedToPlaylist)
        XCTAssertTrue(bookRepository.read(fakeFolder.id)!.addedToPlaylist)

        subscription.cancel()
        
        // Waiting for the storing of books
        waitSec(duration: 1)
    }
    
    func waitWhenRepoIsReady(repo: JSONBookRepository, dispatcher: PlaylistDispatcher) {
        let expectation = self.expectation(description: "Waiting for the deserializtion call to complete.")
        if repo.isReady {
            expectation.fulfill()
        } else {
            dispatcher.subject
                .sink { event in
                    switch event {
                    case .repositoryIsReady:
                        expectation.fulfill()
                    default:
                        break
                    }
                }.store(in: &disposeBag)
        }
        

        waitForExpectations(timeout: 5)
    }

    private var disposeBag: Set<AnyCancellable> = []
    func readBooksFromRepo() throws {
        let dispatcher = PlaylistDispatcher()
        let audioFileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)
        let bookRepository = try JSONBookRepository(serializer: bookSerializer, dispatcher: dispatcher, storeTo: storageURL)

        waitWhenRepoIsReady(repo: bookRepository, dispatcher: dispatcher)

        var isFirstRequestProcessed = false
        bookRepository.subject.sink { books in
            isFirstRequestProcessed = true
            if books.count == 1 {
                XCTAssertEqual(books[0].title, self.realFolder.title)
                // repo must subscribe to books changes and store books
                // addedToPlaylist prop has been changed after processing in the addBooksToPlaylistDomainService
                XCTAssertFalse(books[0].addedToPlaylist)
            } else {
                XCTFail()
            }
        }.store(in: &disposeBag)

        XCTAssertTrue(isFirstRequestProcessed)

        // repo must destroy fake books, that have no source
        XCTAssertFalse(FileManager.default.fileExists(atPath: bookRepository.getBookStoreURL(fakeBook).path))
    }
}
