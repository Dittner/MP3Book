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

    @Published var isLoading = false
    @Published var books: [Book] = []

    private let context: PlaylistContext
    private var disposeBag: Set<AnyCancellable> = []

    init() {
        logInfo(msg: "BookListVM init")
        context = PlaylistContext.shared

        context.bookRepository.subject
            .sink { books in
                self.books = books.filter { $0.addedToPlaylist }.sorted(by: { $0.title < $1.title })

            }.store(in: &disposeBag)
    }
}
