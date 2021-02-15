//
//  BookSerializerTests.swift
//  MP3BookTests
//
//  Created by Alexander Dittner on 13.02.2021.
//

@testable import MP3Book
import XCTest

class BookSerializerTests: XCTestCase {
    var book: Book!
    var dispatcher: PlaylistDispatcher!

    override func setUpWithError() throws {
        dispatcher = PlaylistDispatcher()
        let file1 = AudioFile(id: "file1", name: "file1", source: .documents, path: "1984/file1.mp3", duration: 300, index: 0, dispatcher: dispatcher)
        let file2 = AudioFile(id: "file2", name: "file2", source: .documents, path: "1984/file2.mp3", duration: 200, index: 1, dispatcher: dispatcher)
        book = Book(uid: UID(), folderPath: "documents/1984", title: "1984", files: [file1, file2], totalDuration: 6000, dispatcher: dispatcher)
    }

    func test() throws {
        let audioFileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)

        let serializedData = bookSerializer.serialize(book)
        let deserializedBook = try bookSerializer.deserialize(data: serializedData)

        XCTAssertTrue(equals(b1: book, b2: deserializedBook))
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
            if b1file.path != b2file.path { return false }
            if b1file.playlistID != b2file.playlistID { return false }
            if b1file.duration != b2file.duration { return false }
            if b1file.index != b2file.index { return false }
        }

        return true
    }
}
