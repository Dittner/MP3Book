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

class Book: ObservableObject {
    let uid: UID
    let id: ID
    let folderPath: String
    let playlistID: String
    let title: String
    let files: [AudioFile]
    let source: AudioFileSource

    @Published var playState: PlayState = .stopped
    @Published var progress: Int = 0
    @Published var curFileIndex: Int = 0
    @Published var isDamaged: Bool = false
    @Published var addedToPlaylist: Bool = true

    private(set) var sortType: AudioFilesSortType = .none

    init(uid: UID, playlistPersistentID: UInt64, title: String, files: [AudioFile]) {
        self.uid = uid
        id = playlistPersistentID.description
        self.title = title
        source = .iPodLibrary
        playlistID = playlistPersistentID.description
        folderPath = ""
        self.files = files
        notifyStateChanged()
    }

    init(uid: UID, folderPath: String, title: String, files: [AudioFile]) {
        self.uid = uid
        id = folderPath
        self.folderPath = folderPath
        playlistID = ""
        self.title = title
        source = .documents
        self.files = files
        notifyStateChanged()
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func notifyStateChanged() {
        $playState
            .removeDuplicates()
            .dropFirst()
            .sink { _ in
                PlaylistDomainEventDispatcher.shared.model.send(PlaylistDomainEvent.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)

        $curFileIndex
            .removeDuplicates()
            .dropFirst()
            .sink { _ in
                PlaylistDomainEventDispatcher.shared.model.send(PlaylistDomainEvent.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)

        $addedToPlaylist
                .removeDuplicates()
                .dropFirst()
                .sink { value in
                    let isDamaged = self.isDamaged
                    let added = self.addedToPlaylist
                    PlaylistDomainEventDispatcher.shared.model.send(PlaylistDomainEvent.bookStateChanged(book: self))
                }
                .store(in: &disposeBag)
    }

    func sort(_ sortType: AudioFilesSortType) {
        if self.sortType != sortType {
            self.sortType = sortType
        }
    }
}
