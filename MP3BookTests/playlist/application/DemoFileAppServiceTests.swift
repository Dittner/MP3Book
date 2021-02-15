//
//  DemoFileAppServiceTests.swift
//  MP3BookTests
//
//  Created by Alexander Dittner on 05.02.2021.
//

@testable import MP3Book
import XCTest

class DemoFileAppServiceTests: XCTestCase {
    let destFolderName: String = "Test"
    let srcFileName: String = "test.mp3"

    override func tearDownWithError() throws {
        let destDemoFolderURL = URLS.documentsURL.appendingPathComponent(destFolderName)
        if FileManager.default.fileExists(atPath: destDemoFolderURL.path) {
            try FileManager.default.removeItem(atPath: destDemoFolderURL.path)
        }
    }

    func testCopyDemoFileToDocuments() throws {
        let fileManager = FileManager.default
        let destDemoFolderURL = URLS.documentsURL.appendingPathComponent(destFolderName)
        let destDemoFileUrl = destDemoFolderURL.appendingPathComponent(srcFileName)

        XCTAssertFalse(fileManager.fileExists(atPath: destDemoFileUrl.path))

        let service = DemoFileAppService()
        try service.copyDemoFile(srcFileName: srcFileName, to: destDemoFolderURL)
        XCTAssertTrue(fileManager.fileExists(atPath: destDemoFileUrl.path))
    }
}
