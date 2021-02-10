//
//  LibraryVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class BookListVM: ObservableObject {
    static var shared: BookListVM = BookListVM()

    @Published var isModalSheetShown = false

    private let context: PlaylistContext
    init() {
        logInfo(msg: "BookListVM init")
        context = PlaylistContext.shared
    }
}
