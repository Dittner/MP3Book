//
//  BookSerializer.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation
enum BookSerializerError: DetailedError {
    case propertyNotFound(name: String, bookTitle: String)
    case bookmarksFileNotFound(bookTitle: String)
}

class BookSerializer: IBookSerializer {
    let fileSerializer: IAudioFileSerializer
    let dispatcher: PlaylistDispatcher

    init(fileSerializer: IAudioFileSerializer, dispatcher: PlaylistDispatcher) {
        self.fileSerializer = fileSerializer
        self.dispatcher = dispatcher
    }

    func serialize(_ b: Book) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["uid"] = b.uid
        dict["title"] = b.title
        dict["source"] = b.source.rawValue
        dict["sortType"] = b.sortType.rawValue
        dict["title"] = b.title
        dict["folderPath"] = b.folderPath
        dict["playlistID"] = b.playlistID
        dict["addedToPlaylist"] = b.addedToPlaylist
        dict["curFileProgress"] = b.audioFileColl.curFileProgress
        dict["curFileIndex"] = b.audioFileColl.curFileIndex
        dict["rate"] = b.rate
        dict["isDamaged"] = b.isDamaged

        var filesDict: [[String: Any]] = []
        for f in b.audioFileColl.files {
            filesDict.append(fileSerializer.serialize(f))
        }
        dict["files"] = filesDict

        var marksDict: [[String: Any]] = []
        for bookmark in b.bookmarkColl.bookmarks {
            var mDict: [String: Any] = [:]
            mDict["uid"] = bookmark.uid
            mDict["comment"] = bookmark.comment
            mDict["time"] = bookmark.time
            mDict["fileUID"] = bookmark.file.uid
            marksDict.append(mDict)
        }
        dict["bookmarks"] = marksDict

        return dict
    }

    func deserialize(data: [String: Any]) throws -> Book {
        let res: Book

        guard let title = data["title"] as? String, title.count > 0 else { throw BookSerializerError.propertyNotFound(name: "title", bookTitle: "") }
        guard let uid = data["uid"] as? UID else { throw BookSerializerError.propertyNotFound(name: "uid", bookTitle: title) }
        guard let sourceInt = data["source"] as? Int, let source = AudioFileSource(rawValue: sourceInt) else { throw BookSerializerError.propertyNotFound(name: "source", bookTitle: title) }
        guard let sortTypeInt = data["sortType"] as? Int, let sortType = AudioFilesSortType(rawValue: sortTypeInt) else { throw BookSerializerError.propertyNotFound(name: "sortType", bookTitle: title) }

        let files = try readFiles(data: data, bookTitle: title)

        var fileHash: [UID: AudioFile] = [:]
        files.forEach { fileHash[$0.uid] = $0 }

        let bookmarks = try readBookmarks(data: data, fileHash: fileHash, bookTitle: title)

        if source == .documents {
            guard let folderPath = data["folderPath"] as? String, folderPath.count > 0 else { throw BookSerializerError.propertyNotFound(name: "folderPath", bookTitle: title) }
            res = Book(uid: uid, folderPath: folderPath, title: title, files: files, bookmarks: bookmarks, sortType: sortType, dispatcher: dispatcher)
        } else {
            guard let playlistID = data["playlistID"] as? String, playlistID.count > 0 else { throw BookSerializerError.propertyNotFound(name: "playlistID", bookTitle: title) }

            res = Book(uid: uid, playlistID: playlistID, title: title, files: files, bookmarks: bookmarks, sortType: sortType, dispatcher: dispatcher)
        }

        res.addedToPlaylist = data["addedToPlaylist"] as? Bool ?? false
        res.audioFileColl.curFileIndex = data["curFileIndex"] as? Int ?? 0
        res.audioFileColl.curFileProgress = data["curFileProgress"] as? Int ?? 0
        res.rate = data["rate"] as? Float ?? 1.0
        res.isDamaged = data["isDamaged"] as? Bool ?? false

        return res
    }

    func readFiles(data: [String: Any], bookTitle: String) throws -> [AudioFile] {
        var res: [AudioFile] = []
        if let list = data["files"] as? [[String: Any]], list.count > 0 {
            for fileData in list {
                try res.append(fileSerializer.deserialize(data: fileData))
            }
        } else {
            throw BookSerializerError.propertyNotFound(name: "files", bookTitle: bookTitle)
        }

        return res
    }

    func readBookmarks(data: [String: Any], fileHash: [UID: AudioFile], bookTitle: String) throws -> [Bookmark] {
        var res: [Bookmark] = []
        if let list = data["bookmarks"] as? [[String: Any]] {
            var bookmarks: [Bookmark] = []
            for bookmarkData in list {
                guard let uid = bookmarkData["uid"] as? UID else { throw BookSerializerError.propertyNotFound(name: "bookmark.uid", bookTitle: bookTitle) }
                guard let time = bookmarkData["time"] as? Int else { throw BookSerializerError.propertyNotFound(name: "bookmark.time", bookTitle: bookTitle) }
                guard let fileUID = bookmarkData["fileUID"] as? UID else { throw BookSerializerError.propertyNotFound(name: "bookmark.fileUID", bookTitle: bookTitle) }

                guard let file = fileHash[fileUID] else { throw BookSerializerError.bookmarksFileNotFound(bookTitle: bookTitle) }

                let m = Bookmark(uid: uid, file: file, time: time, comment: bookmarkData["comment"] as? String ?? "")
                bookmarks.append(m)
            }
            res = bookmarks

        } else {
            throw BookSerializerError.propertyNotFound(name: "bookmarks", bookTitle: bookTitle)
        }

        return res
    }
}
