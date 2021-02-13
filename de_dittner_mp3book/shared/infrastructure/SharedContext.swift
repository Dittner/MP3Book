//
//  SharedContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class SharedContext {
    static var shared: SharedContext = SharedContext()
    let libraryContext: LibraryContext
    let playlistContext: PlaylistContext

    init() {
        print("SharedContext initialized")

        libraryContext = LibraryContext.shared
        playlistContext = PlaylistContext.shared

        subscribeToFoldersPort()
        subscribeToPlaylistsPort()
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func subscribeToFoldersPort() {
        LibraryContext.shared.foldersPort.subject
            .filter { $0.count > 0 }
            .map { folders in
                FolderToMP3BookMapper(repo: self.playlistContext.bookRepository).convert(from: folders)
            }
            .sink { books in
                do {
                    try self.playlistContext.addBooksToPlaylistDomainService.add(books, from: .documents)
                } catch {
                    logErr(msg: error.localizedDescription)
                }
            }
            .store(in: &disposeBag)
    }

    private func subscribeToPlaylistsPort() {
        LibraryContext.shared.playlistsPort.subject
            .filter { $0.count > 0 }
            .map { playlists in
                PlaylistToMP3BookMapper(repo: self.playlistContext.bookRepository).convert(from: playlists)
            }
            .sink { books in
                do {
                    try self.playlistContext.addBooksToPlaylistDomainService.add(books, from: .iPodLibrary)
                } catch {
                    logErr(msg: error.localizedDescription)
                }
            }
            .store(in: &disposeBag)
    }
}
