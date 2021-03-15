//
//  Bookmark.swift
//  MP3Book
//
//  Created by Alexander Dittner on 20.02.2021.
//

import Foundation
struct Bookmark: Identifiable {
    let id: ID
    let uid: UID
    let file: AudioFile
    let time: Int
    let comment: String

    init(uid: UID, file: AudioFile, time: Int, comment: String) {
        self.uid = uid
        id = uid.description
        self.file = file
        self.time = time
        self.comment = comment
    }
}

extension Bookmark: Comparable {
    static func < (lhs: Bookmark, rhs: Bookmark) -> Bool {
        if lhs.file.name == rhs.file.name {
            if lhs.time == rhs.time {
                return false
            } else {
                return lhs.time < rhs.time
            }

        } else {
            return lhs.file.name < rhs.file.name
        }
    }

    static func == (lhs: Bookmark, rhs: Bookmark) -> Bool {
        return lhs.uid == rhs.uid
    }
}
