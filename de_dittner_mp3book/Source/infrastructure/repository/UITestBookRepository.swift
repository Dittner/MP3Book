//
//  UITestBookRepository.swift
//  MP3Book
//
//  Created by Alexander Dittner on 16.03.2021.
//

import Combine
import Foundation

class UITestBookRepository: IBookRepository {
    let subject = CurrentValueSubject<[Book], Never>([])

    private let dispatcher: PlaylistDispatcher
    private(set) var isReady: Bool = true
    private var hash: [ID: Book] = [:]

    init(dispatcher: PlaylistDispatcher) {
        logInfo(msg: "TestBookRepository init")
        self.dispatcher = dispatcher
    }

    func has(_ bookID: ID) -> Bool {
        return hash[bookID] != nil
    }

    func read(_ bookID: ID) -> Book? {
        return hash[bookID]
    }

    func remove(_ bookID: ID) {}

    func write(_ books: [Book]) {
        guard books.count > 2 && subject.value.count == 0 else { return }

        let b = books[2]
        b.bookmarkColl.addMark(Bookmark(uid: UID(), file: b.audioFileColl.files[0], time: 0, comment: "Some comment"))
        b.bookmarkColl.addMark(Bookmark(uid: UID(), file: b.audioFileColl.files[0], time: 5, comment: "Some comment"))
        b.audioFileColl.curFileIndex = 2
        b.audioFileColl.curFileProgress = b.audioFileColl.files[2].duration / 2

        books[0].addedToPlaylist = false

        UserDefaults.standard.set(b.id, forKey: Constants.keys.lastPlayedBookID)
        for b in books { hash[b.id] = b }
        subject.send(books)
    }
}
