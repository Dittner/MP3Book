//
//  Playlist.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Foundation

struct Playlist: Identifiable {
    init(playlistPersistentID: UInt64, title: String, totalDuration: Int, files: [PlaylistFile]) {
        id = playlistPersistentID.description
        self.playlistPersistentID = playlistPersistentID
        self.title = title
        self.totalDuration = totalDuration
        self.files = files
    }

    let id: ID
    let playlistPersistentID: UInt64?
    let title: String
    let totalDuration: Int
    let files: [PlaylistFile]
}

extension Playlist: Equatable, Comparable {
    static func == (lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.title == rhs.title
    }

    static func < (lhs: Playlist, rhs: Playlist) -> Bool {
        return lhs.title < rhs.title
    }
}
