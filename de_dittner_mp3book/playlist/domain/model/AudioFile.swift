//
//  Folder.swift
//  MP3Book
//
//  Created by Alexander Dittner on 01.02.2021.
//

import Combine
import Foundation
import MediaPlayer

class AudioFile: ObservableObject, Identifiable {
    let id: ID
    let source: AudioFileSource
    let path: String
    let playlistID: String
    let name: String
    let index: Int
    let duration: Int
    var book: Book!
    
    @Published var state: PlayState = .stopped
    
    init(id: ID, name: String, source:AudioFileSource, path:String, duration: Int, index: Int) {
        self.id = id
        self.name = name
        self.duration = duration
        self.index = index
        self.source = source
        self.path = path
        self.playlistID = ""
    }
    
    init(id: ID, name: String, source:AudioFileSource, playlistID:String, duration: Int, index: Int) {
        self.id = id
        self.name = name
        self.duration = duration
        self.index = index
        self.source = source
        self.path = ""
        self.playlistID = playlistID
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
