//
//  LibraryContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Foundation
class PlaylistContext {
    static var shared: PlaylistContext = PlaylistContext()    
    var books:[Book] = []

    init() {
        print("PlaylistContext initialized")
    }
}
