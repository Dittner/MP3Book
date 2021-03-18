//
//  BookmarkSerializer.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation

enum BookmarkSerializerError: DetailedError {
    case audioFileNotFound(details: String)
}

struct BookmarkDTO: Codable {
    var uid: UID
    var comment: String
    var time: Int
    var fileUID: UID
}

class BookmarkSerializer {
    let dispatcher: PlaylistDispatcher
    let encoder: JSONEncoder
    let decoder: JSONDecoder

    init(dispatcher: PlaylistDispatcher) {
        self.dispatcher = dispatcher
        encoder = JSONEncoder()
        decoder = JSONDecoder()
    }

    func serialize(_ b: Bookmark) -> BookmarkDTO {
        return BookmarkDTO(uid: b.uid, comment: b.comment, time: b.time, fileUID: b.file.uid)
    }

    func deserialize(dto: BookmarkDTO, fileHash: [UID: AudioFile]) throws -> Bookmark {
        guard let file = fileHash[dto.fileUID] else {
            throw BookmarkSerializerError.audioFileNotFound(details: "By deserialization was a file with uid = \(dto.fileUID) not found")
        }

        return Bookmark(uid: dto.uid, file: file, time: dto.time, comment: dto.comment)
    }
}
