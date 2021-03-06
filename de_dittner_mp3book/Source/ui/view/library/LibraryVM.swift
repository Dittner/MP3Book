//
//  LibraryVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class LibraryVM: ViewModel, ObservableObject {
    @Published var isLoading = false
    @Published var wrappedFolders: [Wrapper<Folder>] = []
    @Published var wrappedPlaylists: [Wrapper<Playlist>] = []
    @Published var isManualHidden: Bool = false
    private let context: MP3BookContextProtocol

    init(context: MP3BookContextProtocol) {
        self.context = context
        super.init(id: .library, navigator: context.ui.navigator)
        logInfo(msg: "LibraryVM init")
    }

    override func screenActivated() {
        super.screenActivated()
        loadFiles()
        isManualHidden = UserDefaults.standard.bool(forKey: Constants.keys.isManualHidden)
    }

    func loadFiles() {
        if isLoading { return }

        isLoading = true
        logInfo(msg: "LibraryVM read files")
        Async.background {
            do {
                let docsContent = try self.context.app.documentsService.read()
                let processedFolders = docsContent.folders.filter { $0.depth < 3 }.sorted(by: { $0 < $1 }).map { Wrapper<Folder>($0) }
                processedFolders.forEach { $0.selected = self.isBookAddedToPlaylist($0.data.id) }

                Async.main {
                    self.wrappedFolders = processedFolders

                    self.context.app.iPodService.read { playlists in
                        let processedPlaylists = playlists.sorted { $0 < $1 }.map { Wrapper<Playlist>($0) }
                        processedPlaylists.forEach { $0.selected = self.isBookAddedToPlaylist($0.data.id) }
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

    private func isBookAddedToPlaylist(_ bookID: ID) -> Bool {
        return context.domain.bookRepository.read(bookID)?.addedToPlaylist ?? false
    }

    func cancel() {
        navigator.goBack(to: .bookList)
    }

    func apply() {
        context.domain.bookFactory.create(from: wrappedFolders.filter { $0.selected }.map { $0.data })
        context.domain.bookFactory.create(from: wrappedPlaylists.filter { $0.selected }.map { $0.data })
        navigator.goBack(to: .bookList)
    }

    func openManual() {
        navigator.navigate(to: .manual)
    }
}

class Wrapper<Element: Identifiable>: ObservableObject, Identifiable {
    @Published var selected = false
    let data: Element
    let id: ID

    init(_ e: Element) where Element.ID == ID {
        data = e
        id = e.id
    }
}
