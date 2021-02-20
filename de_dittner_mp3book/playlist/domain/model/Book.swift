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

class Book: PlaylistDomainEntity, ObservableObject, Identifiable {
    let uid: UID
    let id: ID
    let folderPath: String
    let playlistID: String
    let title: String
    let totalDuration: Int
    private(set) var files: [AudioFile]
    let source: AudioFileSource

    @Published var playState: PlayState = .stopped
    @Published var curFileProgress: Int = 0
    @Published var curFileIndex: Int = 0
    @Published private(set) var curFile: AudioFile
    @Published var rate: Float = 1.0
    @Published var isDamaged: Bool = false
    @Published var bookmarksCount: Int = 0
    @Published var addedToPlaylist: Bool = true

    private(set) var totalDurationAt: [Int: Int] = [:]

    private(set) var sortType: AudioFilesSortType = .none

    init(uid: UID, playlistID: String, title: String, files: [AudioFile], totalDuration: Int, sortType: AudioFilesSortType, dispatcher: PlaylistDispatcher) {
        self.uid = uid
        id = playlistID
        self.title = title
        self.totalDuration = totalDuration
        source = .iPodLibrary
        self.sortType = sortType
        self.playlistID = playlistID
        folderPath = ""
        self.files = files
        curFile = files[0]

        super.init(dispatcher: dispatcher)

        for f in files {
            f.book = self
        }

        sortFiles()
        countTotalComments()
        countTotalDurationAt()
        notifyStateChanged()
    }

    init(uid: UID, folderPath: String, title: String, files: [AudioFile], totalDuration: Int, sortType: AudioFilesSortType, dispatcher: PlaylistDispatcher) {
        self.uid = uid
        id = folderPath
        self.folderPath = folderPath
        playlistID = ""
        self.title = title
        self.totalDuration = totalDuration
        source = .documents
        self.sortType = sortType
        self.files = files
        curFile = files[0]

        super.init(dispatcher: dispatcher)

        for f in files {
            f.book = self
        }

        sortFiles()
        countTotalComments()
        countTotalDurationAt()
        notifyStateChanged()
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func notifyStateChanged() {
        $rate
            .removeDuplicates()
            .dropFirst()
            .sink { _ in
                self.dispatcher.subject.send(PlaylistDomainEvent.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)

        $curFileIndex
            .removeDuplicates()
            .dropFirst()
            .sink { index in
                self.curFile = self.files[index]
                self.dispatcher.subject.send(PlaylistDomainEvent.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)

        $addedToPlaylist
            .removeDuplicates()
            .dropFirst()
            .sink { added in
                self.dispatcher.subject.send(PlaylistDomainEvent.bookStateChanged(book: self))
                self.dispatcher.subject.send(added ? PlaylistDomainEvent.bookToPlaylistAdded(book: self) : PlaylistDomainEvent.bookFromPlaylistRemoved(book: self))
            }
            .store(in: &disposeBag)
    }

    private func countTotalComments() {
        bookmarksCount = files.reduce(0, { $0 + $1.bookmarks.count })
    }

    private func countTotalDurationAt() {
        totalDurationAt = [:]
        var total = 0
        for (index, file) in files.enumerated() {
            totalDurationAt[index] = total
            total += file.duration
        }
    }

    func sort(_ sortType: AudioFilesSortType) {
        if source == .iPodLibrary, self.sortType != sortType {
            self.sortType = sortType

            sortFiles()

            if curFileIndex != 0 || curFileProgress != 0 {
                let curFileID = curFile.id
                for (index, file) in files.enumerated() {
                    if file.id == curFileID {
                        curFileIndex = index
                        break
                    }
                }
            }

            countTotalDurationAt()
            dispatcher.subject.send(PlaylistDomainEvent.bookStateChanged(book: self))
        }
    }

    private func sortFiles() {
        if sortType == .none {
            files = files.sorted { $0.index < $1.index }
        } else {
            files = files.sorted { $0.name < $1.name }
        }
    }
}
