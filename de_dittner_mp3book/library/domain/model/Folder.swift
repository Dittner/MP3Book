//
//  Folder.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Foundation

enum FileSource: Int16 {
    case documents = 0
    case iPodLibrary
}

struct Folder {
    init(folderPath: String, title: String, parentFolderName: String?, totalDuration: Int, files: [File], depth: Int) {
        source = FileSource.documents
        id = folderPath
        self.folderPath = folderPath
        playlistPersistentID = nil
        self.title = title
        isSubfolder = parentFolderName != nil
        self.parentFolderName = parentFolderName ?? ""
        self.totalDuration = totalDuration
        self.files = files
        self.depth = depth
    }

    init(playlistPersistentID: UInt64, title: String, totalDuration: Int, files: [File], depth: Int) {
        source = FileSource.iPodLibrary
        self.playlistPersistentID = playlistPersistentID
        folderPath = nil
        self.title = title
        id = self.playlistPersistentID!.description + "-" + self.title
        isSubfolder = false
        parentFolderName = ""
        self.totalDuration = totalDuration
        self.files = files
        self.depth = depth
    }

    let suid: SUID = SUID()
    let id: String
    let folderPath: String?
    let playlistPersistentID: UInt64?
    let title: String
    let source: FileSource
    let totalDuration: Int
    let files: [File]
    let isSubfolder: Bool
    let parentFolderName: String
    let depth: Int
}

extension Folder: Equatable, Comparable {
    static func == (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.parentFolderName == rhs.parentFolderName && lhs.title == rhs.title
    }

    static func < (lhs: Folder, rhs: Folder) -> Bool {
        return lhs.parentFolderName + lhs.title < rhs.parentFolderName + rhs.title
    }
}
