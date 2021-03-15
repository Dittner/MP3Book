//
//  Folder.swift
//  MP3Book
//
//  Created by Alexander Dittner on 01.02.2021.
//

import Combine
import Foundation

class AudioFile: PlaylistDomainEntity, ObservableObject, Identifiable {
    let uid: UID
    let id: ID
    let source: AudioFileSource
    let path: String?
    let playlistID: UInt64?
    let name: String
    let index: Int
    let duration: Int
    var book: Book!

    init(uid: UID, id: ID, name: String, source: AudioFileSource, path: String, duration: Int, index: Int, dispatcher: PlaylistDispatcher) {
        self.uid = uid
        self.id = id
        self.name = name
        self.duration = duration
        self.index = index
        self.source = source
        self.path = path
        playlistID = nil

        super.init(dispatcher: dispatcher)
    }

    init(uid: UID, id: ID, name: String, source: AudioFileSource, playlistID: UInt64, duration: Int, index: Int, dispatcher: PlaylistDispatcher) {
        self.uid = uid
        self.id = id
        self.name = name
        self.duration = duration
        self.index = index
        self.source = source
        path = nil
        self.playlistID = playlistID

        super.init(dispatcher: dispatcher)
    }

    func getURL() -> URL? {
        if source == .documents, let filePath = path {
            return URLS.documentsURL.appendingPathComponent(filePath)
        } else if source == .iPodLibrary, let playlistID = playlistID {
            return URL(string: "ipod-library://item/item.mp3?id=" + playlistID.description)
        }
        return nil
    }

    var description: String {
        if source == .iPodLibrary {
            return name + " in playlist «" + book.title + "»"
        } else if source == .documents, let filePath = path {
            return filePath
        } else {
            return "Audio file of " + book.title
        }
    }
}

extension AudioFile: Equatable {
    static func == (lhs: AudioFile, rhs: AudioFile) -> Bool {
        lhs.uid == rhs.uid
    }
}
