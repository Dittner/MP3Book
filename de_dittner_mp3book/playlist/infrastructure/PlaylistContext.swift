//
//  LibraryContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class PlaylistContext {
    static var shared: PlaylistContext = PlaylistContext()
    let bookRepository: IBookRepository

    init() {
        print("PlaylistContext initialized")

        let storageURL = URLS.libraryURL.appendingPathComponent("Storage")
        let audioFileSerializer = AudioFileSerializer()
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer)
        bookRepository = try! JSONBookRepository(serializer: bookSerializer, storeTo: storageURL)

        subscribeToFoldersPort()
        subscribeToPlaylistsPort()
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func subscribeToFoldersPort() {
        LibraryContext.shared.foldersPort.value
            .filter { $0.count > 0 }
            .map { folders -> [Book] in
                FolderToMP3BookMapper(repo: self.bookRepository).convert(folders)
            }
            .sink { books in
                do {
                    try self.bookRepository.write(books)
                } catch {
                    logErr(msg: error.localizedDescription)
                }
            }
            .store(in: &disposeBag)
    }

    private func subscribeToPlaylistsPort() {
        LibraryContext.shared.playlistsPort.value
            .filter { $0.count > 0 }
            .map { playlists -> [Book] in
                PlaylistToMP3BookMapper(repo: self.bookRepository).convert(playlists)
            }
            .sink { books in
                do {
                    try self.bookRepository.write(books)
                } catch {
                    logErr(msg: error.localizedDescription)
                }
            }
            .store(in: &disposeBag)
    }
}
