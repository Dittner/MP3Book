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

    init(playlistMapper: PlaylistToMP3BookMapper, iPodAppService: IPodAppService) {
        self.iPodAppService = iPodAppService
        self.playlistMapper = playlistMapper
    }

    func run(_ b: Book) {
        guard let playlistID = UInt64(b.playlistID) else { return }
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

        b.audioFileColl = AudioFileColl(files: newFiles)
        b.bookmarkColl = BookmarkColl(bookmarks: updatedBookmarks)
        if oldCurFileIndex < b.audioFileColl.count {
            b.audioFileColl.curFileIndex = oldCurFileIndex
            if let curFile = b.audioFileColl.curFile, oldCurFileProgress < curFile.duration {
                b.audioFileColl.curFileProgress = oldCurFileProgress
            }
        }

        b.playMode = .audioFile
        b.coll = b.audioFileColl
        b.isDamaged = false
    }
}
