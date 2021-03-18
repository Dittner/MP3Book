//
//  BookSerializer.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation

enum BookSerializerError: DetailedError {
    case invalidBookDTO(details: String)
}

struct BookDTO: Codable {
    var uid: UID
    var title: String
    var source: AudioFileSource
    var sortType: AudioFilesSortType
    var folderPath: String?
    var playlistID: UInt64?
    var addedToPlaylist: Bool
    var curFileProgress: Int
    var curFileIndex: Int
    var rate: Float
    var isDamaged: Bool
    var files: [AudioFileDTO]
    var bookmarks: [BookmarkDTO]
}

class BookSerializer: IBookSerializer {
    private let fileSerializer: AudioFileSerializer
    private let bookmarkSerializer: BookmarkSerializer
    private let dispatcher: PlaylistDispatcher
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(dispatcher: PlaylistDispatcher) {
        fileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        bookmarkSerializer = BookmarkSerializer(dispatcher: dispatcher)
        self.dispatcher = dispatcher
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    func serialize(_ b: Book) throws -> Data {
        var files: [AudioFileDTO] = []
        for f in b.audioFileColl.files {
            files.append(fileSerializer.serialize(f))
        }

        var bookmarks: [BookmarkDTO] = []
        for m in b.bookmarkColl.bookmarks {
            bookmarks.append(bookmarkSerializer.serialize(m))
        }

        let dto = BookDTO(uid: b.uid,
                          title: b.title,
                          source: b.source,
                          sortType: b.sortType,
                          folderPath: b.folderPath,
                          playlistID: b.playlistID,
                          addedToPlaylist: b.addedToPlaylist,
                          curFileProgress: b.audioFileColl.curFileProgress,
                          curFileIndex: b.audioFileColl.curFileIndex,
                          rate: b.rate,
                          isDamaged: b.isDamaged,
                          files: files,
                          bookmarks: bookmarks)

        return try encoder.encode(dto)
    }

    func deserialize(data: Data) throws -> Book {
        let dto = try decoder.decode(BookDTO.self, from: data)
        let book: Book

        let files = try readFiles(files: dto.files, bookTitle: dto.title)
        var fileHash: [UID: AudioFile] = [:]
        files.forEach { fileHash[$0.uid] = $0 }

        let bookmarks = try readBookmarks(bookmarks: dto.bookmarks, fileHash: fileHash, bookTitle: dto.title)

        if let folderPath = dto.folderPath {
            book = Book(uid: dto.uid, folderPath: folderPath, title: dto.title, files: files, bookmarks: bookmarks, sortType: dto.sortType, dispatcher: dispatcher)
        } else if let playlistID = dto.playlistID {
            book = Book(uid: dto.uid, playlistID: playlistID, title: dto.title, files: files, bookmarks: bookmarks, sortType: dto.sortType, dispatcher: dispatcher)
        } else {
            throw BookSerializerError.invalidBookDTO(details: "Book «\(dto.title)» has nil folderPath and nil playlistID")
        }

        book.addedToPlaylist = dto.addedToPlaylist
        book.audioFileColl.curFileIndex = dto.curFileIndex
        book.audioFileColl.curFileProgress = dto.curFileProgress
        book.rate = dto.rate
        book.isDamaged = dto.isDamaged

        return book
    }

    func readFiles(files: [AudioFileDTO], bookTitle: String) throws -> [AudioFile] {
        var res: [AudioFile] = []
        for dto in files {
            try res.append(fileSerializer.deserialize(dto: dto))
        }

        return res
    }

    func readBookmarks(bookmarks: [BookmarkDTO], fileHash: [UID: AudioFile], bookTitle: String) throws -> [Bookmark] {
        var res: [Bookmark] = []
        for dto in bookmarks {
            try res.append(bookmarkSerializer.deserialize(dto: dto, fileHash: fileHash))
        }

        return res
    }
}
