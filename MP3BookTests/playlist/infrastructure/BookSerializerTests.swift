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
        let file1 = AudioFile(uid: UID(), id: "file1", name: "file1", source: .documents, path: "1984/file1.mp3", duration: 300, index: 0, dispatcher: dispatcher)
        let file2 = AudioFile(uid: UID(), id: "file2", name: "file2", source: .documents, path: "1984/file2.mp3", duration: 200, index: 1, dispatcher: dispatcher)
        let mark = Bookmark(uid: UID(), file: file1, time: 60, comment: "No comment")
        book = Book(uid: UID(), folderPath: "documents/1984", title: "1984", files: [file1, file2], bookmarks: [mark], sortType: .none, dispatcher: dispatcher)
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
        if b1.audioFileColl.count != b2.audioFileColl.count { return false }
        for (index, b1file) in b1.audioFileColl.files.enumerated() {
            let b2file = b2.audioFileColl.files[index]

            if b1file.id != b2file.id { return false }
            if b1file.name != b2file.name { return false }
            if b1file.source != b2file.source { return false }
            if b1file.path != b2file.path { return false }
            if b1file.playlistID != b2file.playlistID { return false }
            if b1file.duration != b2file.duration { return false }
            if b1file.index != b2file.index { return false }
        }
        
        for (index, b1mark) in b1.bookmarkColl.bookmarks.enumerated() {
            let b2mark = b2.bookmarkColl.bookmarks[index]

            if b1mark.id != b2mark.id { return false }
            if b1mark.uid != b2mark.uid { return false }
            if b1mark.file.name != b2mark.file.name { return false }
            if b1mark.time != b2mark.time { return false }
            if b1mark.comment != b2mark.comment { return false }
        }

        return true
    }
}
