//
//  FolderToMP3BookMapper.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation

class FolderToBookMapper: FolderToBookMapperProtocol {
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
                let b = Book(uid: UID(), folderPath: folder.path!, title: folder.title, files: files, bookmarks: [], sortType: .none, dispatcher: dispatcher)
                newBooks.append(b)
            }
        }

        return newBooks
    }

    private func convert(_ files: [FolderFile]) -> [AudioFile] {
        var res = [AudioFile]()
        let sortedFiles = files.sorted(by: <)
        for (index, f) in sortedFiles.enumerated() {
            let audioFile = AudioFile(uid: UID(), id: f.id, name: f.name, source: .documents, path: f.path, duration: f.duration, index: index, dispatcher: dispatcher)
            res.append(audioFile)
        }
        return res
    }
}
