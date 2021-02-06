//
//  DemoFileAppServiceTests.swift
//  MP3BookTests
//
//  Created by Alexander Dittner on 05.02.2021.
//

@testable import MP3Book
import XCTest

class DemoFileAppServiceTests: XCTestCase {
    let destFolderName: String = "test"
    let srcFileName: String = "test.mp3"

    override func tearDownWithError() throws {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destDemoFolderURL = documentsURL.appendingPathComponent(destFolderName)
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destDemoFolderURL.path) {
            try fileManager.removeItem(atPath: destDemoFolderURL.path)
            print("Demo folder has been removed")
        } else {
            print("Demo folder does not exist")
        }
    }

    func testCopyDemoFileToDocuments() throws {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destDemoFolderURL = documentsURL.appendingPathComponent(destFolderName)
        let destDemoFileUrl = destDemoFolderURL.appendingPathComponent(srcFileName)

        XCTAssertFalse(fileManager.fileExists(atPath: destDemoFileUrl.path))

        let service = DemoFileAppService()
        try service.copyDemoFileToDocumentsFolder(srcFileName: srcFileName, destFolderName: destFolderName)
        XCTAssertTrue(fileManager.fileExists(atPath: destDemoFileUrl.path))
    }
}
