//
//  PlaylistToMP3BookMapper.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation

class PlaylistToMP3BookMapper {
    let repo: IBookRepository
    init(repo: IBookRepository) {
        self.repo = repo
    }

    func convert(from: [Playlist]) -> [Book] {
        var newBooks: [Book] = []
        for playlist in from {
            if let b = repo.read(playlist.id) {
                newBooks.append(b)
            } else {
                let files = convert(playlist.files)
                let b = Book(uid: UID(), playlistPersistentID: playlist.playlistPersistentID!, title: playlist.title, files: files)
                newBooks.append(b)
            }
        }

        return newBooks
    }

    func convert(_ files: [PlaylistFile]) -> [AudioFile] {
        var res = [AudioFile]()
        for (index, f) in files.enumerated() {
            let playlistID = f.playlistItem!.persistentID.description
            let audioFile = AudioFile(id: f.id, name: f.name, source: .iPodLibrary, playlistID: playlistID, duration: f.duration, index: index)
            res.append(audioFile)
        }
        return res
    }
}
