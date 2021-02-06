//
//  DemoFileAppServiceTests.swift
//  MP3BookTests
//
//  Created by Alexander Dittner on 05.02.2021.
//

@testable import MP3Book
import XCTest

class DocumentsAppServiceTests: XCTestCase {
    let destFolderName: String = "test"
    let srcFolderName: String = "George Orwell – 1984"

    //remove test folder with mp3 files
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
        let copyService = DemoFileAppService()
        try copyService.copyDemoFileToDocumentsFolder(srcFileName: srcFolderName, destFolderName: destFolderName)
        
        let docsService = DocumentsAppService()
        let content = docsService.readFrom(dirUrl: destDemoFolderURL)

        XCTAssertEqual(content.folders.count, 4)
        XCTAssertEqual(content.files.count, 8)
        XCTAssertEqual(content.totalDuration, 2431)
    }
}
