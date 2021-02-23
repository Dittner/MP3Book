//
//  PlayerAppService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 15.02.2021.
//

import Combine
import Foundation

enum PlayerAppServiceError: DetailedError {
    case fileURLNotFound(details: String)
}

class PlayerAppService: MediaAPINotificationDelegate, ObservableObject {
    @Published private(set) var book: Book? = nil
    var fileColl: FileCollection?

    let api: MediaAPI

    init(api: MediaAPI) {
        self.api = api
        api.delegate = self
    }

    var subscription: AnyCancellable?
    func play(_ b: Book) {
        api.stop()
        if let curBook = book, curBook.uid != b.uid {
            curBook.playState = .stopped
            api.setPlayRate(value: b.rate)
        }

        subscription?.cancel()
        book = b
        fileColl = b.coll

        subscription = b.$coll
            .sink { coll in
                self.pause()
                self.fileColl = coll
            }

        guard var coll = fileColl else { return }
        guard let curFile = coll.curFile else { return }

        if coll.curFileProgress == curFile.duration {
            if coll.curFileIndex < coll.count - 1 {
                coll.curFileIndex += 1
            } else {
                coll.curFileIndex = 0
            }
        }

        if let url = curFile.getURL() {
            api.play(url: url, position: coll.curFileProgress, duration: curFile.duration)
        } else {
            logErr(msg: "fileURLNotFound, book: " + b.title + ", file: " + curFile.description)
        }
    }

    func pause() {
        api.stop()
    }

    func updatePosition(value: Double) {
        guard var coll = fileColl else { return }
        api.updatePosition(value: value)
        coll.curFileProgress = Int(value)
    }

    func updateRate(value: Float) {
        api.setPlayRate(value: value)
        book?.rate = value
    }

    // -------------------------------------
    //
    //   Media API
    //
    // -------------------------------------

    func mediaAPIDidStartPlayFile() {
        guard let b = book else { return }
        b.playState = .playing
    }

    func mediaAPIDidFinishPlayFile() {
        guard let b = book else { return }
        b.playState = .paused
    }

    func mediaAPIDidCompletePlayFile() {
        guard let b = book, var coll = fileColl else { return }

        if coll.curFileIndex < coll.count - 1, b.playMode == .audioFile {
            coll.curFileIndex += 1
            play(b)
        } else if let curFile = coll.curFile {
            coll.curFileProgress = curFile.duration
            pause()
        }
    }

    func mediaAPIWillPlayNextFile() {
        playNext()
    }

    func playNext() {
        guard let b = book, var coll = fileColl else { return }

        if coll.curFileIndex < coll.count - 1 {
            coll.curFileIndex += 1
            play(b)
        } else {
            coll.curFileIndex = 0
            play(b)
        }
    }

    func mediaAPIWillPlayPrevFile() {
        playPrev()
    }

    func playPrev() {
        guard let b = book, var coll = fileColl else { return }

        if coll.curFileIndex > 0 {
            coll.curFileIndex -= 1
            play(b)
        } else {
            coll.curFileIndex = coll.count - 1
            play(b)
        }
    }

    func mediaAPIDidPlaybackTimeChange(time: Int) {
        guard var coll = fileColl else { return }
        coll.curFileProgress = time
    }

    func mediaAPIBeginInterruption() {
    }

    func mediaAPIErrorOccurred(err: DetailedError) {
        logErr(msg: err.localizedDescription)
    }
}
