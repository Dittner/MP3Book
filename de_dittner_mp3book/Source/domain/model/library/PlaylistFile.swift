//
//  PlaylistFile.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Foundation
import MediaPlayer

struct PlaylistFile {
    let id: ID
    let playlistItem: MPMediaItem?
    let duration: Int
    let name: String

    init(mediaItem m: MPMediaItem) {
        playlistItem = m
        id = m.persistentID.description
        name = m.title ?? "No name"
        duration = Int(m.playbackDuration)
    }
}
