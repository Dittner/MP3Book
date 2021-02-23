//
//  LibraryVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation
import MediaPlayer

class AudioFileListVM: ViewModel, ObservableObject {
    static var shared: AudioFileListVM = AudioFileListVM(id: .audioFileList)

    @Published var selectedBook: Book?
    @Published var playRateSelectorShown: Bool = false
    @Published var addBookmarkFormShown: Bool = false

    private let context: PlaylistContext
    let player: PlayerAppService
    private var disposeBag: Set<AnyCancellable> = []

    override init(id: ScreenID) {
        logInfo(msg: "AudioFileListVM init")
        context = PlaylistContext.shared
        player = context.playerAppService

        super.init(id: id)

        $playRateSelectorShown.sink { value in
            print("playRateSelectorShown = \(value)")
        }.store(in: &disposeBag)
    }
    
    override func screenDeactivated() {
        super.screenDeactivated()
        selectedBook?.playMode = .audioFile
    }

    func goBack() {
        navigator.goBack(to: .bookList)
    }

    func addBookmark(file: AudioFile, time: Int, comment: String) {
        player.book?.bookmarkColl.addMark(Bookmark(uid: UID(), file: file, time: time, comment: comment))
    }

    func resortFiles() {
        if let b = selectedBook {
            pause()
            b.sort(b.sortType == .none ? .title : .none)
        }
    }

    func removeBookmark(_ m: Bookmark) {
        if let b = selectedBook {
            if b.bookmarkColl.curBookmark == m {
                player.pause()
            }

            b.bookmarkColl.removeMark(m)
        }
    }

    // -------------------------------------
    //
    //   PLAYER
    //
    // -------------------------------------

    func playFile(_ f: AudioFile) {
        guard let b = f.book else { return }

        if b.playState == .playing, b.audioFileColl.curFile == f {
            player.pause()
        } else {
            b.coll.curFileIndex = f.index
            player.play(b)
        }
        UserDefaults.standard.set(b.id, forKey: "lastPlayedBookID")
    }

    func playBookmark(_ mark: Bookmark) {
        guard let b = mark.file.book else { return }

        if b.playState == .playing, b.bookmarkColl.curBookmark == mark {
            player.pause()
        } else {
            b.bookmarkColl.curFileIndex = b.bookmarkColl.bookmarks.firstIndex(of: mark) ?? 0
            player.play(b)
        }
        UserDefaults.standard.set(b.id, forKey: "lastPlayedBookID")
    }

    func updateProgress(value: Double) {
        player.updatePosition(value: value)
    }

    func play(_ b: Book) {
        player.play(b)
    }

    func pause() {
        player.pause()
    }

    func playNext() {
        player.playNext()
    }

    func playPrev() {
        player.playPrev()
    }

    func updateRate(value: Float) {
        player.updateRate(value: value)
    }
}
