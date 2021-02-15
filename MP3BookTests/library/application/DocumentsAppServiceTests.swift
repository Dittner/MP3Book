//
//  DemoFileAppServiceTests.swift
//  MP3BookTests
//
//  Created by Alexander Dittner on 05.02.2021.
//

@testable import MP3Book
import XCTest

class DocumentsAppServiceTests: XCTestCase {
    let destFolderName: String = "Test"
    let srcFolderName: String = "George Orwell – 1984"

    override func tearDownWithError() throws {
        let destDemoFolderURL = URLS.documentsURL.appendingPathComponent(destFolderName)
        if FileManager.default.fileExists(atPath: destDemoFolderURL.path) {
            try FileManager.default.removeItem(atPath: destDemoFolderURL.path)
        }
    }

    func testCopyDemoFileToDocuments() throws {
        let destDemoFolderURL = URLS.documentsURL.appendingPathComponent(destFolderName)
        let copyService = DemoFileAppService()
        try copyService.copyDemoFile(srcFileName: srcFolderName, to: destDemoFolderURL)
        
        let docsService = DocumentsAppService()
        let content = try docsService.readFrom(dirUrl: destDemoFolderURL)

        XCTAssertEqual(content.folders.count, 4)
        XCTAssertEqual(content.files.count, 8)
        XCTAssertEqual(content.totalDuration, 2431)
    }
}
