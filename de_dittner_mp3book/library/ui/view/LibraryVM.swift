//
//  LibraryVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class LibraryVM: ObservableObject {
    static var shared: LibraryVM = LibraryVM()

    @Published var isLoading = false
    @Published var folders: [FolderWrapper] = []
    @Published var playlists: [FolderWrapper] = []

    private let context: LibraryContext
    init() {
        logInfo(msg: "LibraryVM init")
        context = LibraryContext.shared
    }

    func loadFiles() {
        if isLoading {return}
        
        isLoading = true
        logInfo(msg: "LibraryVM loadFiles")
        Async.background {
            do {
                let docsContent = try self.context.documentsAppService.read()
                let processedFolders = docsContent.folders.filter { $0.depth < 3 }.sorted(by: { $0 < $1 }).map { FolderWrapper($0) }
                let processedPlaylists = self.context.iPodAppService.read().sorted(by: { $0 < $1 }).map { FolderWrapper($0) }
                Async.main {
                    self.folders = processedFolders
                    self.playlists = processedPlaylists
                    self.isLoading = false
                }
            } catch {
                logErr(msg: error.localizedDescription)
                self.isLoading = false
            }
        }
    }

    func apply() {
        context.selectedFolders = folders.filter { $0.selected }.map { $0.folder }
    }
}

class FolderWrapper: ObservableObject, Identifiable {
    @Published var selected = false
    let folder: Folder
    let id: String
    init(_ f: Folder) {
        folder = f
        id = folder.id
    }
}
