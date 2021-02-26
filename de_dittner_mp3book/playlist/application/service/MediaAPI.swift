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
    func mediaAPIWillStop()
    func mediaAPIWillPlay()
    func mediaAPIWillUpdatePosition(value: Double)
    func mediaAPIDidPlaybackTimeChange(time: Int)
    func mediaAPIInterruptionBegan()
    func mediaAPIInterruptionEnded()
    func mediaAPIErrorOccurred(error: MediaAPIError)
}

enum MediaAPIError: DetailedError {
    case fileNotPlayable
    case fileDecodingFailed(details: String)
}

class MediaAPI {
    private let mediaPlayer: AVPlayer
    var delegate: MediaAPINotificationDelegate!

    init() {
        mediaPlayer = AVPlayer(playerItem: nil)
        observeRemoteControls()
        observeMediaPlayer()
        setupBackgroundMode()
    }

    // -------------------------------------
    //
    //   Remote Controls
    //
    // -------------------------------------

    func observeRemoteControls() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = true
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.changePlaybackPositionCommand.isEnabled = true

        commandCenter.playCommand.addTarget { [unowned self] _ in
            self.delegate.mediaAPIWillPlay()
            return .success
        }

        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            self.delegate.mediaAPIWillStop()
            return .success
        }

        commandCenter.previousTrackCommand.addTarget { [unowned self] _ in
            self.delegate.mediaAPIWillPlayPrevFile()
            return .success
        }

        commandCenter.nextTrackCommand.addTarget { [unowned self] _ in
            self.delegate.mediaAPIWillPlayNextFile()
            return .success
        }

        commandCenter.changePlaybackPositionCommand.addTarget { [unowned self] event in
            if let event = event as? MPChangePlaybackPositionCommandEvent {
                self.delegate.mediaAPIWillUpdatePosition(value: event.positionTime)
                return .success
            } else {
                return .commandFailed
            }
        }

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleInterruption),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
    }

    @objc func handleInterruption(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let interruptionTypeRawValue = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt,
              let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRawValue) else {
            return
        }

        switch interruptionType {
        case .began:
            if userInfo[AVAudioSessionInterruptionWasSuspendedKey] == nil {
                delegate.mediaAPIInterruptionBegan()
                logInfo(msg: "Interruption is began: \(notification.description)")
            }
        case .ended:
            delegate.mediaAPIInterruptionEnded()
            logInfo(msg: "Interruption is ended: \(notification.description)")
        @unknown default:
            logWarn(msg: "Unknown interruptionType: \(interruptionType)")
        }
    }

    // -------------------------------------
    //
    //   OS Media Player
    //
    // -------------------------------------

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
        delegate.mediaAPIErrorOccurred(error: MediaAPIError.fileDecodingFailed(details: notification.description))
    }

    // -------------------------------------
    //
    //   Background Mode
    //
    // -------------------------------------

    func setupBackgroundMode() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

        } catch {
            logErr(msg: "Setting category to AVAudioSession.Category.playback failed: " + error.localizedDescription)
        }
    }

    // ------------------------------------------------------------------

    private var playRate: Float = 1.0
    func setPlayRate(value: Float) {
        if playRate != value {
            playRate = value
            if playState == .playing {
                mediaPlayer.rate = value
            }
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

    // -------------------------------------
    //
    //   PLAY
    //
    // -------------------------------------

    func play(url: URL, position: Int, duration: Int) {
        if AVAsset(url: url).isPlayable {
            let item = AVPlayerItem(url: url)
            mediaPlayer.replaceCurrentItem(with: item)

            let time = CMTime(seconds: Double(position), preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            mediaPlayer.seek(to: time)
            mediaPlayer.playImmediately(atRate: playRate)
            playState = .playing
        } else {
            delegate.mediaAPIErrorOccurred(error: MediaAPIError.fileNotPlayable)
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
