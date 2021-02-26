//
//  ReloadAudioFilesFromIPodLibraryService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 25.02.2021.
//

import Foundation
class ReloadAudioFilesFromIPodLibraryService {
    private let iPodAppService: IPodAppService
    private let playlistMapper: PlaylistToMP3BookMapper
    private let booksRepository: IBookRepository

    init(playlistMapper: PlaylistToMP3BookMapper, iPodAppService: IPodAppService, booksRepository: IBookRepository) {
        self.iPodAppService = iPodAppService
        self.playlistMapper = playlistMapper
        self.booksRepository = booksRepository
    }

    func run(_ b: Book) {
        guard let playlistID = b.playlistID else { return }
        guard let playlist = iPodAppService.getPlaylist(persistentID: playlistID) else { return }

        let newFiles = playlistMapper.convert(playlist.files)

        var fileHash: [String: AudioFile] = [:]
        for file in newFiles {
            fileHash[file.name] = file
            file.book = b
        }

        var updatedBookmarks: [Bookmark] = []
        for mark in b.bookmarkColl.bookmarks {
            if let f = fileHash[mark.file.name] {
                updatedBookmarks.append(Bookmark(uid: UID(), file: f, time: mark.time, comment: mark.comment))
            }
        }

        let oldCurFileIndex = b.audioFileColl.curFileIndex
        let oldCurFileProgress = b.audioFileColl.curFileProgress

        let newBook = Book(uid: UID(), playlistID: playlistID, title: b.title, files: newFiles, bookmarks: updatedBookmarks, sortType: b.sortType, dispatcher: b.dispatcher)

        if oldCurFileIndex < b.audioFileColl.count {
            newBook.audioFileColl.curFileIndex = oldCurFileIndex
            if let curFile = newBook.audioFileColl.curFile, oldCurFileProgress < curFile.duration {
                newBook.audioFileColl.curFileProgress = oldCurFileProgress
            }
        }

        booksRepository.remove(b.id)
        try? booksRepository.write([newBook])
    }
}
