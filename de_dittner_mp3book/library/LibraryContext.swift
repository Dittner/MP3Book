//
//  LibraryContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Foundation
class LibraryContext {
    static var shared: LibraryContext = LibraryContext()

    let documentsAppService: DocumentsAppService
    let iPodAppService: IPodAppService
    
    var selectedFolders:[Folder] = []

    init() {
        print("LibraryContext initialized")
        documentsAppService = DocumentsAppService()
        iPodAppService = IPodAppService()
    }
}
