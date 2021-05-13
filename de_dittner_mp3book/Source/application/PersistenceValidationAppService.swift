//
//  ValidationDomainService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 25.02.2021.
//

import MediaPlayer

enum BookValidationResult: Int {
    case ok = 0
    case bookNotFound
    case fileNotFound
}

class PersistenceValidationAppService {
    private let iPodAppService: IPodAppService
    private let reloadFilesService: ReloadAudioFilesFromIPodLibraryService
    private let alertBox: AlertBox
    init(iPodAppService: IPodAppService, reloadFilesService: ReloadAudioFilesFromIPodLibraryService, alertBox: AlertBox) {
        self.iPodAppService = iPodAppService
        self.reloadFilesService = reloadFilesService
        self.alertBox = alertBox
    }

    func notifyBookIsDamaged(_ b: Book) {
        switch validate(b: b) {
        case .bookNotFound:
            if b.source == .documents {
                alertBox.show(title: "NoBookInTheAppData", details: "CheckBookFolder \(b.folderPath!)")
            } else {
                alertBox.show(title: "NoBookInTheMediaLib", details: "CheckPlaylist \(b.title)")
            }
        case .fileNotFound:
            guard let f = b.audioFileColl.curFile else { return }
            if b.source == .documents {
                alertBox.show(title: "NoAudioFile", details: "CheckFileExistInAppData \(f.name)")
            } else {
                alertBox.show(title: "NoAudioFile", details: "CheckFileExistInMediaLib \(b.title) \(f.name)")
            }
        default: break
        }
    }

    func recoverBook(_ b: Book) {
        let result = validate(b: b)
        switch result {
        case .ok:
            b.isDamaged = false
        case .bookNotFound:
            b.isDamaged = true
            notifyBookIsDamaged(b)
        case .fileNotFound:
            if b.source == .iPodLibrary {
                reloadFilesService.run(b)
                if !b.destroyed {
                    notifyBookIsDamaged(b)
                }
            } else {
                b.isDamaged = true
                notifyBookIsDamaged(b)
            }
        }
    }

    private func validate(b: Book) -> BookValidationResult {
        if validateBook(b) {
            if let f = b.coll.curFile, validateFile(f) {
                return .ok
            } else {
                return .fileNotFound
            }
        } else {
            return .bookNotFound
        }
    }

    private func validateBook(_ b: Book) -> Bool {
        if let url = b.getURL() {
            if b.source == .documents {
                if !url.fileExists() {
                    return false
                }
            } else if let id = b.playlistID, !iPodAppService.playlistExists(persistentID: id) {
                return false
            }
        }

        return true
    }

    private func validateFile(_ f: AudioFile) -> Bool {
        if let url = f.getURL() {
            if f.source == .documents {
                if !url.fileExists() {
                    return false
                }
            } else if url.isIPodItemLink() && !AVAsset(url: url).isPlayable {
                return false
            }
        } else {
            return false
        }
        return true
    }
}
