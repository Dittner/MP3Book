//
//  Book.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

enum PlayState: Int {
    case stopped = 0
    case paused
    case playing
}

enum AudioFilesSortType: Int {
    case none = 0
    case title
}

enum AudioFileSource: Int {
    case documents = 0
    case iPodLibrary
}

typealias ID = String

class Book:ObservableObject {
    let uid:UID
    let id:ID
    let folderPath:String
    let playlistID:String
    let title:String
    let files:[AudioFile]
    let source:AudioFileSource
    
    @Published var playState:PlayState = .stopped
    @Published var progress:Int = 0
    @Published var curFileIndex:Int = 0
    @Published var isDamaged:Bool = false
    @Published var pendingToRemove:Bool = false
    
    private(set) var sortType:AudioFilesSortType = .none
    
    init(uid: UID, playlistPersistentID: UInt64, title: String, files: [AudioFile]) {
        self.uid = uid
        self.id = playlistPersistentID.description
        self.title = title
        self.source = .iPodLibrary
        playlistID = playlistPersistentID.description
        self.folderPath = ""
        self.files = files
    }

    init(uid: UID, folderPath: String, title: String, files: [AudioFile]) {
        self.uid = uid
        self.id = folderPath
        self.folderPath = folderPath
        self.playlistID = ""
        self.title = title
        self.source = .documents
        self.files = files
    }
    
    func sort(_ sortType:AudioFilesSortType) {
        if self.sortType != sortType {
            self.sortType = sortType
        }
    }
}
