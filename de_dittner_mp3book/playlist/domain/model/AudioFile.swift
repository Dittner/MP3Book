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
    let url: URL
    let name: String
    let index: Int
    let duration: Int
    var book: Book!
    
    @Published var state: PlayState = .stopped
    
    init(id: ID, name: String, source:AudioFileSource, url:URL, duration: Int, index: Int) {
        self.id = id
        self.name = name
        self.duration = duration
        self.index = index
        self.source = source
        self.url = url
    }

    var description: String {
        if source == .iPodLibrary {
            return name + " in playlist «" + book.title + "»"
        } else if source == .documents {
            return url.absoluteString
        } else {
            return "Audio file of " + book.title
        }
    }
}
