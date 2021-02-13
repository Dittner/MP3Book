//
//  BookSerializer.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation
enum BookSerializerError: DetailedError {
    case propertyNotFound(name: String, bookTitle: String)
}

class BookSerializer: IBookSerializer {
    let fileSerializer: IAudioFileSerializer

    init(fileSerializer: IAudioFileSerializer) {
        self.fileSerializer = fileSerializer
    }

    func serialize(_ b: Book) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["uid"] = b.uid
        dict["title"] = b.title
        dict["source"] = b.source.rawValue
        dict["title"] = b.title
        dict["folderPath"] = b.folderPath
        dict["playlistID"] = b.playlistID
        dict["addedToPlaylist"] = b.addedToPlaylist
        dict["progress"] = b.progress
        dict["curFileIndex"] = b.curFileIndex

        var filesDict: [[String: Any]] = []
        for f in b.files {
            filesDict.append(fileSerializer.serialize(f))
        }
        dict["files"] = filesDict

        return dict
    }

    func deserialize(data: [String: Any]) throws -> Book {
        let res:Book
        
        guard let title = data["title"] as? String, title.count > 0 else { throw BookSerializerError.propertyNotFound(name: "title", bookTitle: "") }
        guard let uid = data["uid"] as? UID else { throw BookSerializerError.propertyNotFound(name: "uid", bookTitle: title) }
        guard let sourceInt = data["source"] as? Int, let source = AudioFileSource(rawValue: sourceInt) else { throw BookSerializerError.propertyNotFound(name: "source", bookTitle: title) }

        var files: [AudioFile] = []
        if let fileList = data["files"] as? [[String: Any]], fileList.count > 0 {
            for fileData in fileList {
                try files.append(fileSerializer.deserialize(data: fileData))
            }
        } else {
            throw BookSerializerError.propertyNotFound(name: "files", bookTitle: title)
        }

        if source == .documents {
            guard let folderPath = data["folderPath"] as? String, folderPath.count > 0 else { throw BookSerializerError.propertyNotFound(name: "folderPath", bookTitle: title) }
            res =  Book(uid: uid, folderPath: folderPath, title: title, files: files)
        } else {
            guard let playlistID = data["playlistID"] as? UInt64 else { throw BookSerializerError.propertyNotFound(name: "playlistID", bookTitle: title) }

            res = Book(uid: uid, playlistPersistentID: playlistID, title: title, files: files)
        }
        
        
        guard let addedToPlaylist = data["addedToPlaylist"] as? Bool else { throw BookSerializerError.propertyNotFound(name: "addedToPlaylist", bookTitle: title) }
        guard let progress = data["progress"] as? Int else { throw BookSerializerError.propertyNotFound(name: "progress", bookTitle: title) }
        guard let curFileIndex = data["curFileIndex"] as? Int else { throw BookSerializerError.propertyNotFound(name: "curFileIndex", bookTitle: title) }
        res.addedToPlaylist = addedToPlaylist
        res.curFileIndex = curFileIndex
        res.progress = progress
        
        return res
    }
}
