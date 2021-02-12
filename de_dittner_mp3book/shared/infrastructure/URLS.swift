//
//  URLS.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation
class URLS {
    static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    static var libraryURL: URL {
        FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    }
}
