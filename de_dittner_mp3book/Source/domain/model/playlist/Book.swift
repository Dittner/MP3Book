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

enum PlayMode: Int {
    case audioFile
    case bookmark
}

protocol FileCollection {
    // curFileProgress
    var curFileProgress: Int { get set }
    var curFileProgressPublished: Published<Int> { get }
    var curFileProgressPublisher: Published<Int>.Publisher { get }

    // curFileIndex
    var curFileIndex: Int { get set }
    var curFileIndexPublished: Published<Int> { get }
    var curFileIndexPublisher: Published<Int>.Publisher { get }

    // curFile
    var curFile: AudioFile? { get }
    var curFilePublished: Published<AudioFile?> { get }
    var curFilePublisher: Published<AudioFile?>.Publisher { get }

    // count
    var count: Int { get }
    var countPublished: Published<Int> { get }
    var countPublisher: Published<Int>.Publisher { get }
}

class AudioFileColl: FileCollection, ObservableObject {
    // curFileProgress
    @Published var curFileProgress: Int = 0
    var curFileProgressPublished: Published<Int> { _curFileProgress }
    var curFileProgressPublisher: Published<Int>.Publisher { $curFileProgress }

    // curFileIndex
    @Published var curFileIndex: Int = 0
    var curFileIndexPublished: Published<Int> { _curFileIndex }
    var curFileIndexPublisher: Published<Int>.Publisher { $curFileIndex }

    // curFile
    @Published private(set) var curFile: AudioFile?
    var curFilePublished: Published<AudioFile?> { _curFile }
    var curFilePublisher: Published<AudioFile?>.Publisher { $curFile }

    // count
    @Published internal var count: Int = 0
    var countPublished: Published<Int> { _count }
    var countPublisher: Published<Int>.Publisher { $count }

    @Published internal var files: [AudioFile]

    private var disposeBag: Set<AnyCancellable> = []
    init(files: [AudioFile]) {
        self.files = files
        count = files.count

        $curFileIndex
            .filter { $0 < self.count }
            .sink { index in
                if self.curFile != self.files[index] {
                    self.curFileProgress = 0
                    self.curFile = index < self.files.count ? self.files[index] : nil
                } else if self.count == 1 {
                    self.curFileProgress = 0
                }
            }.store(in: &disposeBag)
    }
}

class BookmarkColl: FileCollection, ObservableObject {
    // curFileProgress
    @Published var curFileProgress: Int = 0
    var curFileProgressPublished: Published<Int> { _curFileProgress }
    var curFileProgressPublisher: Published<Int>.Publisher { $curFileProgress }

    // curFileIndex
    @Published var curFileIndex: Int = 0
    var curFileIndexPublished: Published<Int> { _curFileIndex }
    var curFileIndexPublisher: Published<Int>.Publisher { $curFileIndex }

    // curFile
    @Published private(set) var curFile: AudioFile?
    var curFilePublished: Published<AudioFile?> { _curFile }
    var curFilePublisher: Published<AudioFile?>.Publisher { $curFile }

    // count
    @Published private(set) var count: Int = 0
    var countPublished: Published<Int> { _count }
    var countPublisher: Published<Int>.Publisher { $count }

    @Published private(set) var curBookmark: Bookmark?
    @Published private(set) var bookmarks: [Bookmark] = []

    private var disposeBag: Set<AnyCancellable> = []
    init(bookmarks: [Bookmark]) {
        self.bookmarks = bookmarks.sorted(by: <)
        count = bookmarks.count

        $curFileIndex
            .filter { $0 < self.count }
            .sink { index in
                if self.curBookmark != self.bookmarks[index] {
                    self.curBookmark = index < self.bookmarks.count ? self.bookmarks[index] : nil
                    self.curFile = self.curBookmark?.file
                    self.curFileProgress = self.curBookmark?.time ?? 0
                } else if self.count == 1 {
                    self.curFileProgress = self.curBookmark?.time ?? 0
                }
            }.store(in: &disposeBag)
    }

    func addMark(_ m: Bookmark) {
        bookmarks.append(m)
        bookmarks = bookmarks.sorted { $0 < $1 }
        count = bookmarks.count
        if let curBookmark = curBookmark, curBookmark > m {
            curFileIndex += 1
        }
    }

    func removeMark(_ m: Bookmark) {
        for (index, bookmark) in bookmarks.enumerated() {
            if bookmark.time == m.time && bookmark.comment == m.comment {
                bookmarks.remove(at: index)
                count = bookmarks.count
                if let curBookmark = curBookmark, curBookmark > m {
                    curFileIndex -= 1
                }
                return
            }
        }
    }
}

typealias ID = String

class Book: PlaylistDomainEntity, ObservableObject, Identifiable {
    let uid: UID
    let id: ID
    let folderPath: String?
    let playlistID: UInt64?
    let title: String
    let totalDuration: Int
    let source: AudioFileSource

    @Published var playState: PlayState = .stopped
    @Published var rate: Float = 1.0
    @Published var isDamaged: Bool = false
    @Published var addedToPlaylist: Bool = true
    @Published var playMode: PlayMode = .audioFile

    @Published private(set) var bookmarkColl: BookmarkColl
    @Published private(set) var audioFileColl: AudioFileColl
    @Published var coll: FileCollection

    var destroyed: Bool = false
    private(set) var totalDurationAt: [Int: Int] = [:]

    private(set) var sortType: AudioFilesSortType = .none

    init(uid: UID, playlistID: UInt64, title: String, files: [AudioFile], bookmarks: [Bookmark], sortType: AudioFilesSortType, dispatcher: PlaylistDispatcher) {
        self.uid = uid
        id = playlistID.description
        self.title = title
        totalDuration = files.reduce(0, { $0 + $1.duration })
        source = .iPodLibrary
        self.sortType = sortType
        self.playlistID = playlistID
        folderPath = nil
        let afc = AudioFileColl(files: files)
        audioFileColl = afc
        bookmarkColl = BookmarkColl(bookmarks: bookmarks)
        coll = afc

        super.init(dispatcher: dispatcher)

        for f in files {
            f.book = self
        }

        sortFiles()
        countTotalDurationAt()
        notifyStateChanged()
    }

    init(uid: UID, folderPath: String, title: String, files: [AudioFile], bookmarks: [Bookmark], sortType: AudioFilesSortType, dispatcher: PlaylistDispatcher) {
        self.uid = uid
        id = folderPath
        self.folderPath = folderPath
        playlistID = nil
        self.title = title
        totalDuration = files.reduce(0, { $0 + $1.duration })
        source = .documents
        self.sortType = sortType
        let afc = AudioFileColl(files: files)
        audioFileColl = afc
        bookmarkColl = BookmarkColl(bookmarks: bookmarks)
        coll = afc

        super.init(dispatcher: dispatcher)

        for f in files {
            f.book = self
        }

        sortFiles()
        countTotalDurationAt()
        notifyStateChanged()
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func notifyStateChanged() {
        $rate
            .removeDuplicates()
            .dropFirst()
            .sink { _ in
                self.dispatcher.notify(.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)

        $playState
            .removeDuplicates()
            .dropFirst()
            .filter { $0 != .playing }
            .sink { _ in
                self.dispatcher.notify(.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)

        $isDamaged
            .removeDuplicates()
            .dropFirst()
            .sink { value in
                self.dispatcher.notify(.bookStateChanged(book: self))
                if value {
                    self.dispatcher.notify(.bookIsDamaged(book: self))
                }
            }
            .store(in: &disposeBag)

        audioFileColl.$curFileIndex
            .dropFirst()
            .sink { _ in
                self.dispatcher.notify(.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)

        bookmarkColl.$count
            .dropFirst()
            .sink { _ in
                self.dispatcher.notify(.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)

        $addedToPlaylist
            .removeDuplicates()
            .dropFirst()
            .sink { added in
                self.dispatcher.notify(.bookStateChanged(book: self))
                self.dispatcher.notify(added ? .bookToPlaylistAdded(book: self) : .bookFromPlaylistRemoved(book: self))
            }
            .store(in: &disposeBag)

        $playMode
            .removeDuplicates()
            .sink { playMode in
                self.coll = playMode == .audioFile ? self.audioFileColl : self.bookmarkColl
            }
            .store(in: &disposeBag)

        $bookmarkColl
            .dropFirst()
            .sink { _ in
                self.dispatcher.notify(PlaylistDomainEvent.bookStateChanged(book: self))
            }
            .store(in: &disposeBag)
    }

    func getURL() -> URL? {
        if source == .documents, let path = folderPath {
            return URLS.documentsURL.appendingPathComponent(path)
        } else if source == .iPodLibrary, let playlistID = playlistID {
            return URL(string: "ipod-library://item/item.mp3?id=" + playlistID.description)
        }
        return nil
    }

    private func countTotalDurationAt() {
        totalDurationAt = [:]
        var total = 0
        for (index, file) in audioFileColl.files.enumerated() {
            totalDurationAt[index] = total
            total += file.duration
        }
    }

    func sort(_ sortType: AudioFilesSortType) {
        if source == .iPodLibrary, self.sortType != sortType {
            self.sortType = sortType

            sortFiles()

            if let curFile = audioFileColl.curFile, audioFileColl.curFileIndex != 0 || audioFileColl.curFileProgress != 0 {
                if let newFileIndex = audioFileColl.files.firstIndex(of: curFile) {
                    audioFileColl.curFileIndex = newFileIndex
                }
            }

            countTotalDurationAt()
            dispatcher.notify(.bookStateChanged(book: self))
        }
    }

    private func sortFiles() {
        if sortType == .none {
            audioFileColl.files = audioFileColl.files.sorted { $0.index < $1.index }
        } else {
            audioFileColl.files = audioFileColl.files.sorted { $0.name < $1.name }
        }
    }
}

extension Book: Equatable {
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.uid == rhs.uid
    }
}
