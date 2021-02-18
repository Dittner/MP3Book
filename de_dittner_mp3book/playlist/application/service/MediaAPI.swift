//
//  MediaAPI.swift
//  MP3Book
//
//  Created by Alexander Dittner on 15.02.2021.
//

import AVFoundation
import Foundation
import MediaPlayer

enum MediaPlayerState: Int {
    case stopped = 0
    case playing
}

protocol MediaAPINotificationDelegate {
    func mediaAPIDidStartPlayFile()
    func mediaAPIDidFinishPlayFile()
    func mediaAPIDidCompletePlayFile()
    func mediaAPIWillPlayNextFile()
    func mediaAPIWillPlayPrevFile()
    func mediaAPIDidPlaybackTimeChange(time: Int)
    func mediaAPIBeginInterruption()
    func mediaAPIErrorOccurred(err: DetailedError)
}

enum MediaAPIError: DetailedError {
    case fileNotPlayable(url: String)
    case fileDecodingFailed(url: String, details: String)
}

class MediaAPI {
    private let mediaPlayer: AVPlayer
    var delegate: MediaAPINotificationDelegate!

    init() {
        mediaPlayer = AVPlayer(playerItem: nil)
        observeMediaPlayer()
    }

    private var playRate: Float = 1.0
    func setPlayRate(value: Float) {
        if playRate != value {
            playRate = value
            playRate = value
            mediaPlayer.rate = value
        }
    }

    private(set) var currentTime: Int {
        get {
            let time = mediaPlayer.currentTime()
            if time.isNumeric && !time.isIndefinite {
                return Int(mediaPlayer.currentTime().seconds)
            } else {
                return 0
            }
        }
        set(value) {
            if playState == .playing {
                mediaPlayer.seek(to: CMTime(seconds: Double(value), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
            }
        }
    }

    private(set) var playState: MediaPlayerState = .stopped {
        didSet {
            if playState != oldValue {
                if playState == .playing {
                    addPeriodicTimeObserver()
                    delegate.mediaAPIDidStartPlayFile()
                } else {
                    removePeriodicTimeObserver()
                    delegate.mediaAPIDidFinishPlayFile()
                }
                
            }
        }
    }

    private var timeObserverToken: Any?
    func addPeriodicTimeObserver() {
        // Invoke callback every half second
        let interval = CMTime(seconds: 1,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Queue on which to invoke the callback
        let mainQueue = DispatchQueue.main
        // Add time observer
        timeObserverToken = mediaPlayer.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) {
            [weak self] time in
            guard let self = self else { return }
            if time.seconds > 0 {
                self.delegate.mediaAPIDidPlaybackTimeChange(time: Int(time.seconds.rounded()))
            }
        }
    }

    func removePeriodicTimeObserver() {
        if timeObserverToken != nil {
            mediaPlayer.removeTimeObserver(timeObserverToken!)
            timeObserverToken = nil
        }
    }

    private func timerProcessing() {
        if playState == .playing {
            delegate.mediaAPIDidPlaybackTimeChange(time: currentTime)
        }
    }

    func observeMediaPlayer() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mediaPlayerDidPlayToEndTime),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mediaPlayerDecodeErrorDidOccur),
                                               name: NSNotification.Name.AVPlayerItemFailedToPlayToEndTime,
                                               object: nil)
    }

    @objc func mediaPlayerDidPlayToEndTime(notification: NSNotification) {
        delegate.mediaAPIDidCompletePlayFile()
    }

    @objc func mediaPlayerDecodeErrorDidOccur(notification: NSNotification) {
        let url = curSoundFile?.url.description ?? "Unknown"
        delegate.mediaAPIErrorOccurred(err: MediaAPIError.fileDecodingFailed(url: url, details: notification.description))
    }

    // -------------------------------------
    //
    //   PLAY
    //
    // -------------------------------------

    var curSoundFile: SoundFile?
    func play(url: URL, position: Int, duration: Int) {
        curSoundFile = SoundFile(url: url, position: position, duration: duration)

        if AVAsset(url: url).isPlayable {
            let item = AVPlayerItem(url: url)
            mediaPlayer.replaceCurrentItem(with: item)

            let time = CMTime(seconds: Double(position), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            mediaPlayer.seek(to: time)
            mediaPlayer.playImmediately(atRate: playRate)
            playState = .playing
        } else {
            let urlDescription = url.isIpodItemLink() ? url.description : url.relativePath
            delegate.mediaAPIErrorOccurred(err: MediaAPIError.fileNotPlayable(url: urlDescription))
        }
    }

    func stop() {
        playState = .stopped
        mediaPlayer.pause()
    }
    
    func updatePosition(value: Double) {
        if playState == .playing {
            mediaPlayer.seek(to: CMTime(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
        }
    }
}

struct SoundFile {
    let url: URL
    let position: Int
    let duration: Int
}
