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

    override func tearDownWithError() throws {
        let destDemoFolderURL = URLS.documentsURL.appendingPathComponent(destFolderName)
        if FileManager.default.fileExists(atPath: destDemoFolderURL.path) {
            try FileManager.default.removeItem(atPath: destDemoFolderURL.path)
        }
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
        let serializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)
        let repo = JSONBookRepository(serializer: serializer, dispatcher: dispatcher, storeTo: storageURL)
        let folderToBookMapper = FolderToBookMapper(repo: repo, dispatcher: dispatcher)
        let playlistToBookMapper = PlaylistToBookMapper(repo: repo, dispatcher: dispatcher)
        let factory = BookFactory(repo: repo, folderToBook: folderToBookMapper, playlistToBook: playlistToBookMapper)

        waitWhenRepoIsReady(repo: repo, dispatcher: dispatcher)

        var isFirstRequestProcessed = false
        var isSecondRequestProcessed = false
        var isThirdRequestProcessed = false

        let subscription = repo.subject.sink { books in
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
                XCTFail("More notifications as required")
            }
        }

        XCTAssertTrue(isFirstRequestProcessed)

        factory.create(from: [realFolder])

        XCTAssertTrue(isSecondRequestProcessed)

        factory.create(from: [fakeFolder])
        fakeBook = repo.read(fakeFolder.id)

        XCTAssertTrue(isThirdRequestProcessed)

        XCTAssertTrue(repo.has(realFolder.id))
        XCTAssertTrue(repo.has(fakeFolder.id))
        XCTAssertFalse(repo.read(realFolder.id)!.addedToPlaylist)
        XCTAssertTrue(repo.read(fakeFolder.id)!.addedToPlaylist)

        subscription.cancel()

        waitWhenRepoStoredBooks(repo: repo, dispatcher: dispatcher)
    }

    func waitWhenRepoIsReady(repo: JSONBookRepository, dispatcher: PlaylistDispatcher) {
        let expectation = XCTestExpectation(description: "waitWhenRepoIsReady")
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

        wait(for: [expectation], timeout: 5.0)
    }

    func waitWhenRepoStoredBooks(repo: JSONBookRepository, dispatcher: PlaylistDispatcher) {
        let expectation = XCTestExpectation(description: "waitWhenRepoStoredBooks")

        dispatcher.subject
            .sink { event in
                switch event {
                case .repositoryStoreComplete:
                    expectation.fulfill()
                default:
                    break
                }
            }.store(in: &disposeBag)

        repo.storeChanges()

        wait(for: [expectation], timeout: 5.0)
    }

    private var disposeBag: Set<AnyCancellable> = []
    func readBooksFromRepo() throws {
        let dispatcher = PlaylistDispatcher()
        let audioFileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)
        let bookRepository = JSONBookRepository(serializer: bookSerializer, dispatcher: dispatcher, storeTo: storageURL)

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
                XCTFail("Repo has not the stored book")
            }
        }.store(in: &disposeBag)

        XCTAssertTrue(isFirstRequestProcessed)

        // repo must destroy fake books, that have no source
        XCTAssertFalse(FileManager.default.fileExists(atPath: bookRepository.getBookStoreURL(fakeBook).path))
    }
}
