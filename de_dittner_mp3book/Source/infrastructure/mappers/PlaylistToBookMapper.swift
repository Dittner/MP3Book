//
//  PlaylistToMP3BookMapper.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation

class PlaylistToBookMapper: PlaylistToBookMapperProtocol {
    let repo: IBookRepository
    let dispatcher: PlaylistDispatcher

    init(repo: IBookRepository, dispatcher: PlaylistDispatcher) {
        self.repo = repo
        self.dispatcher = dispatcher
    }

    func convert(from: [Playlist]) -> [Book] {
        var newBooks: [Book] = []
        for playlist in from {
            if let b = repo.read(playlist.id) {
                if playlist.totalDuration != b.totalDuration || b.audioFileColl.count != playlist.files.count{
                    b.updateFiles(files: convert(playlist.files))
                }
                newBooks.append(b)
            } else {
                let files = convert(playlist.files)

                let b = Book(uid: UID(), playlistID: playlist.playlistPersistentID, title: playlist.title, files: files, bookmarks: [], sortType: .none, dispatcher: dispatcher)
                newBooks.append(b)
            }
        }

        return newBooks
    }

    func convert(_ files: [PlaylistFile]) -> [AudioFile] {
        var res = [AudioFile]()
        for (index, f) in files.enumerated() {
            let playlistID = f.playlistItem!.persistentID
            let audioFile = AudioFile(uid: UID(), id: f.id, name: f.name, playlistID: playlistID, duration: f.duration, index: index, dispatcher: dispatcher)
            res.append(audioFile)
        }
        return res
    }
}
