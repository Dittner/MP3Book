//
//  FolderFile.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Foundation
import MediaPlayer

struct FolderFile {
    let id: ID
    let path: String
    let duration: Int
    let name: String

    init(filePath p: String, name: String, duration: Int) {
        path = p
        id = p
        self.name = name
        self.duration = duration
    }
}

extension FolderFile: Comparable {
    static func < (lhs: FolderFile, rhs: FolderFile) -> Bool {
        lhs.path < rhs.path
    }
}
