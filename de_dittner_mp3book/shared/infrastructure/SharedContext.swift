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
    let foldersMapper: FolderToMP3BookMapper
    let playlistMapper: PlaylistToMP3BookMapper
    let reloadAudioFilesFromIPodLibraryService: ReloadAudioFilesFromIPodLibraryService

    init() {
        logInfo(msg: "SharedContext initialized")

        libraryContext = LibraryContext.shared
        playlistContext = PlaylistContext.shared

        foldersMapper = FolderToMP3BookMapper(repo: playlistContext.bookRepository, dispatcher: playlistContext.dispatcher)

        playlistMapper = PlaylistToMP3BookMapper(repo: playlistContext.bookRepository, dispatcher: playlistContext.dispatcher)

        let booksMapper = PlaylistBooksToHashMapper()

        reloadAudioFilesFromIPodLibraryService = ReloadAudioFilesFromIPodLibraryService(playlistMapper: playlistMapper, iPodAppService: LibraryContext.shared.iPodAppService)

        subscribeToFoldersPort(foldersMapper)
        subscribeToPlaylistsPort(playlistMapper)
        subscribeToPlaylistBooksPort(booksMapper)
    }

    func run() {
        // call run to be sure SharedContext has been launched
        logInfo(msg: "App has 3 modules: SharedContext, LibraryContext, PlaylistContext")
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func subscribeToFoldersPort(_ foldersMapper: FolderToMP3BookMapper) {
        LibraryContext.shared.foldersPort.subject
            .dropFirst()
            .map { folders in
                foldersMapper.convert(from: folders)
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

    private func subscribeToPlaylistsPort(_ playlistMapper: PlaylistToMP3BookMapper) {
        LibraryContext.shared.playlistsPort.subject
            .dropFirst()
            .map { playlists in
                playlistMapper.convert(from: playlists)
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

    private func subscribeToPlaylistBooksPort(_ booksMapper: PlaylistBooksToHashMapper) {
        PlaylistContext.shared.playlistBooksPort.subject
            .dropFirst()
            .map { books in
                booksMapper.convert(books)
            }
            .sink { hash in
                LibraryContext.shared.selectedFoldersAnPlaylistsHash = hash
            }
            .store(in: &disposeBag)
    }
}
