//
//  LibraryVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class LibraryVM: ViewModel, ObservableObject {
    static var shared: LibraryVM = LibraryVM(id: .library)

    @Published var isLoading = false
    @Published var wrappedFolders: [Wrapper<Folder>] = []
    @Published var wrappedPlaylists: [Wrapper<Playlist>] = []

    private let context: LibraryContext

    override init(id: ScreenID) {
        logInfo(msg: "LibraryVM init")
        context = LibraryContext.shared

        super.init(id: id)
    }

    override func screenActivated() {
        super.screenActivated()
        loadFiles()
    }

    func loadFiles() {
        if isLoading { return }

        isLoading = true
        logInfo(msg: "LibraryVM read files")
        Async.background {
            do {
                let isSelected = self.context.selectedFoldersAnPlaylistsHash
                let docsContent = try self.context.documentsAppService.read()
                let processedFolders = docsContent.folders.filter { $0.depth < 3 }.sorted(by: { $0 < $1 }).map { Wrapper<Folder>($0) }
                processedFolders.forEach { $0.selected = isSelected[$0.data.id] ?? false }

                Async.main {
                    self.wrappedFolders = processedFolders

                    self.context.iPodAppService.read { playlists in
                        let processedPlaylists = playlists.sorted(by: { $0 < $1 }).map { Wrapper<Playlist>($0) }
                        processedPlaylists.forEach { $0.selected = isSelected[$0.data.id] ?? false }
                        self.wrappedPlaylists = processedPlaylists
                        Async.after(milliseconds: 1000) {
                            self.isLoading = false
                        }
                    }
                }
            } catch {
                logErr(msg: error.localizedDescription)
                self.isLoading = false
            }
        }
    }

    func cancel() {
        navigator.goBack(to: .bookList)
    }

    func apply() {
        context.foldersPort.write(wrappedFolders.filter { $0.selected }.map { $0.data })
        context.playlistsPort.write(wrappedPlaylists.filter { $0.selected }.map { $0.data })
        navigator.goBack(to: .bookList)
    }
}

class Wrapper<Element: Identifiable>: ObservableObject, Identifiable {
    @Published var selected = false
    let data: Element
    let id: ID

    init(_ e: Element) {
        data = e
        id = e.id as! ID
    }
}
