//
//  LibraryContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import SwiftUI

class LibraryContext {
    static var shared: LibraryContext = LibraryContext()

    let documentsAppService: DocumentsAppService
    let iPodAppService: IPodAppService
    
    let foldersPort:OutputPort<Folder>
    let playlistsPort:OutputPort<Playlist>

    init() {
        print("LibraryContext initialized")
        documentsAppService = DocumentsAppService()
        iPodAppService = IPodAppService()
        foldersPort = OutputPort<Folder>()
        playlistsPort = OutputPort<Playlist>()
    }
}

