//
//  FolderToMP3BookMapper.swift
//  MP3Book
//
//  Created by Alexander Dittner on 13.02.2021.
//

import Foundation

class FolderToMP3BookMapper {
    let repo: IBookRepository
    init(repo: IBookRepository) {
        self.repo = repo
    }

    func convert(_ folders: [Folder]) -> [Book] {
        var newBooks: [Book] = []
        for folder in folders {
            if let b = repo.read(folder.id) {
                newBooks.append(b)
            } else {
                let files = convert(folder.files)
                let b = Book(uid: UID(), folderPath: folder.path!, title: folder.title, files: files)
                newBooks.append(b)
            }
        }

        return newBooks
    }
    
    func convert(_ files: [FolderFile]) -> [AudioFile] {
        var res = [AudioFile]()
        for (index, f) in files.enumerated() {
            let fileURL = URL(fileURLWithPath: f.path, relativeTo: URLS.documentsURL)
            let audioFile = AudioFile(id: f.id, name: f.name, source: .documents, url: fileURL, duration: f.duration, index: index)
            res.append(audioFile)
        }
        return res
    }
}
