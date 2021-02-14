//
//  FolderToMP3BookMapper.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation

class FolderToMP3BookMapper {
    let repo: IBookRepository
    let dispatcher: PlaylistDispatcher
    init(repo: IBookRepository, dispatcher: PlaylistDispatcher) {
        self.repo = repo
        self.dispatcher = dispatcher
    }

    func convert(from: [Folder]) -> [Book] {
        var newBooks: [Book] = []
        for folder in from {
            if let b = repo.read(folder.id) {
                newBooks.append(b)
            } else {
                let files = convert(folder.files)
                let b = Book(uid: UID(), folderPath: folder.path!, title: folder.title, files: files, totalDuration: folder.totalDuration, dispatcher: dispatcher)
                newBooks.append(b)
            }
        }

        return newBooks
    }

    func convert(_ files: [FolderFile]) -> [AudioFile] {
        var res = [AudioFile]()
        for (index, f) in files.enumerated() {
            let audioFile = AudioFile(id: f.id, name: f.name, source: .documents, path: f.path, duration: f.duration, index: index, dispatcher: dispatcher)
            res.append(audioFile)
        }
        return res
    }
}
