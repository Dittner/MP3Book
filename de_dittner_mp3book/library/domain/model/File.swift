//
//  File.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Foundation
import MediaPlayer

struct File {
    let suid: SUID = SUID()
    let id: String
    var path: String?
    var playlistItem: MPMediaItem?
    let duration: Int
    let name: String

    init(filePath p: String, name: String, duration: Int) {
        path = p
        id = p
        self.name = name
        self.duration = duration
    }

    init(mediaItem m: MPMediaItem) {
        playlistItem = m
        id = m.persistentID.description
        name = m.title ?? "No name"
        duration = Int(m.playbackDuration)
    }
}
