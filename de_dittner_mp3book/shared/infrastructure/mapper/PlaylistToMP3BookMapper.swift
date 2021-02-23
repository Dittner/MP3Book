//
//  PlaylistToMP3BookMapper.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation

class PlaylistToMP3BookMapper {
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
                newBooks.append(b)
            } else {
                let files = convert(playlist.files)

                let b = Book(uid: UID(), playlistID: playlist.playlistPersistentID!.description, title: playlist.title, files: files, bookmarks: [], sortType: .none, dispatcher: dispatcher)
                newBooks.append(b)
            }
        }

        return newBooks
    }

    func convert(_ files: [PlaylistFile]) -> [AudioFile] {
        var res = [AudioFile]()
        for (index, f) in files.enumerated() {
            let playlistID = f.playlistItem!.persistentID.description
            let audioFile = AudioFile(uid: UID(), id: f.id, name: f.name, source: .iPodLibrary, playlistID: playlistID, duration: f.duration, index: index, dispatcher: dispatcher)
            res.append(audioFile)

            // let url = f.playlistItem!.assetURL!
            // print("Title: \(f.name), ID: \(playlistID), URL: \(url.description)")
        }
        return res
    }
}
