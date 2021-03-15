//
//  Folder.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Foundation

struct Folder: Identifiable {
    init(folderPath: String, title: String, parentFolderName: String?, totalDuration: Int, files: [FolderFile], depth: Int) {
        id = folderPath
        path = folderPath
        self.title = title
        isSubfolder = parentFolderName != nil
        self.parentFolderName = parentFolderName ?? ""
        self.totalDuration = totalDuration
        self.files = files
        self.depth = depth
    }

    let id: ID
    let path: String?
    let title: String
    let totalDuration: Int
    let files: [FolderFile]
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
