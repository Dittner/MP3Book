//
//  Folder.swift
//  MP3Book
//
//  Created by Alexander Dittner on 01.02.2021.
//

import Combine
import Foundation
import MediaPlayer

class AudioFile: PlaylistDomainEntity, ObservableObject, Identifiable {
    let id: ID
    let source: AudioFileSource
    let path: String
    let playlistID: String
    let name: String
    let index: Int
    let duration: Int
    var book: Book!

    init(id: ID, name: String, source: AudioFileSource, path: String, duration: Int, index: Int, dispatcher: PlaylistDispatcher) {
        self.id = id
        self.name = name
        self.duration = duration
        self.index = index
        self.source = source
        self.path = path
        playlistID = ""

        super.init(dispatcher: dispatcher)
    }

    init(id: ID, name: String, source: AudioFileSource, playlistID: String, duration: Int, index: Int, dispatcher: PlaylistDispatcher) {
        self.id = id
        self.name = name
        self.duration = duration
        self.index = index
        self.source = source
        path = ""
        self.playlistID = playlistID

        super.init(dispatcher: dispatcher)
    }

    func getURL() -> URL? {
        return source == .documents ? URLS.documentsURL.appendingPathComponent(path) : URL(string: "ipod-library://item/item.mp3?id=" + playlistID)
    }

    var description: String {
        if source == .iPodLibrary {
            return name + " in playlist «" + book.title + "»"
        } else if source == .documents {
            return path
        } else {
            return "Audio file of " + book.title
        }
    }
}
