//
//  SharedContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation
import UIKit

class SharedContext {
    static var shared: SharedContext = SharedContext()
    let libraryContext: LibraryContext
    let playlistContext: PlaylistContext
    let foldersMapper: FolderToMP3BookMapper
    let playlistMapper: PlaylistToMP3BookMapper
    let reloadAudioFilesFromIPodLibraryService: ReloadAudioFilesFromIPodLibraryService

    init() {
        SharedContext.logAbout()
        logInfo(msg: "SharedContext initialized")

        libraryContext = LibraryContext.shared
        playlistContext = PlaylistContext.shared

        foldersMapper = FolderToMP3BookMapper(repo: playlistContext.bookRepository, dispatcher: playlistContext.dispatcher)

        playlistMapper = PlaylistToMP3BookMapper(repo: playlistContext.bookRepository, dispatcher: playlistContext.dispatcher)

        let booksMapper = PlaylistBooksToHashMapper()

        reloadAudioFilesFromIPodLibraryService = ReloadAudioFilesFromIPodLibraryService(playlistMapper: playlistMapper, iPodAppService: libraryContext.iPodAppService, booksRepository: playlistContext.bookRepository)

        subscribeToFoldersPort(foldersMapper)
        subscribeToPlaylistsPort(playlistMapper)
        subscribeToPlaylistBooksPort(booksMapper)
    }

    // call run to be sure SharedContext has been launched
    func run() {
        addDemoFileIfNeeded()
        logInfo(msg: "App has 3 modules: SharedContext, LibraryContext, PlaylistContext")
    }

    private static func logAbout() {
        var aboutLog: String = "MP3BookLogs\n"
        let ver: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        aboutLog += "v." + ver + "." + build + "\n"

        let device = UIDevice.current
        aboutLog += "simulator: " + device.isSimulator.description + "\n"
        aboutLog += "device: " + device.modelName + "\n"
        aboutLog += "os: " + device.systemName + " " + device.systemVersion + "\n"
        #if DEBUG
            aboutLog += "debug mode\n"
            aboutLog += "docs folder: \\" + URLS.documentsURL.description
        #else
            aboutLog += "release mode\n"
        #endif

        logInfo(msg: aboutLog)
    }

    private func addDemoFileIfNeeded() {
        if !UserDefaults.standard.bool(forKey: "demoFileShown") {
            let service = DemoFileAppService()

            do {
                // copying
                let destDemoFolderURL = URLS.documentsURL.appendingPathComponent("Demo – Three Laws of Robotics")
                try service.copyDemoFile(srcFileName: "record.mp3", to: destDemoFolderURL)
                // creating book
                guard let docsContent = try? libraryContext.documentsAppService.read() else { return }
                let books = foldersMapper.convert(from: docsContent.folders)
                guard let book = books.count > 0 ? books.first : nil else { return }
                // storing book
                try playlistContext.bookRepository.write([book])

                UserDefaults.standard.set(true, forKey: "demoFileShown")
            } catch {
                logErr(msg: error.localizedDescription)
            }
        }
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
