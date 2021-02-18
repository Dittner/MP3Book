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
    @Published var book: Book? = nil
    let api: MediaAPI

    init(api: MediaAPI) {
        self.api = api
        api.delegate = self
    }

    func play(_ b: Book) {
        api.stop()
        if let book = book, book.id != b.id {
            book.playState = .stopped
            api.setPlayRate(value: book.rate)
        }
        book = b
        
        if b.curFileProgress == b.curFile.duration {
            if b.curFileIndex < b.files.count - 1 {
                b.curFileProgress = 0
                b.curFileIndex += 1
            } else {
                b.curFileProgress = 0
                b.curFileIndex = 0
            }
        }

        if let url = b.curFile.getURL() {
            api.play(url: url, position: b.curFileProgress, duration: b.curFile.duration)
        } else {
            logErr(msg: "fileURLNotFound, book: " + b.title + ", file: " + b.curFile.description)
        }
    }

    func pause() {
        api.stop()
    }
    
    func updatePosition(value: Double) {
        api.updatePosition(value: value)
        book?.curFileProgress = Int(value)
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
        guard let b = book else { return }
        if b.curFileIndex < b.files.count - 1 {
            b.curFileProgress = 0
            b.curFileIndex += 1
            play(b)
        } else {
            b.curFileProgress = b.curFile.duration
            pause()
        }
    }

    func mediaAPIWillPlayNextFile() {
        playNext()
    }
    
    func playNext() {
        guard let b = book else { return }
        if b.curFileIndex < b.files.count - 1 {
            b.curFileProgress = 0
            b.curFileIndex += 1
            play(b)
        } else {
            b.curFileProgress = 0
            b.curFileIndex = 0
            play(b)
        }
    }

    func mediaAPIWillPlayPrevFile() {
        playPrev()
    }
    
    func playPrev() {
        guard let b = book else { return }
        if b.curFileIndex > 0 {
            b.curFileProgress = 0
            b.curFileIndex -= 1
            play(b)
        } else {
            b.curFileProgress = 0
            b.curFileIndex = b.files.count - 1
            play(b)
        }
    }

    func mediaAPIDidPlaybackTimeChange(time: Int) {
        guard let b = book else { return }
        b.curFileProgress = time
    }

    func mediaAPIBeginInterruption() {
    }

    func mediaAPIErrorOccurred(err: DetailedError) {
        logErr(msg: err.localizedDescription)
    }
}
