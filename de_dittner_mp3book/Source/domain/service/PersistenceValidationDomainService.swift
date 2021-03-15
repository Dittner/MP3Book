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

class PersistenceValidationDomainService {
    func validate(b: Book) -> BookValidationResult {
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
            } else if let id = b.playlistID, !MP3BookContext.shared.iPodAppService.playlistExists(persistentID: id) {
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
