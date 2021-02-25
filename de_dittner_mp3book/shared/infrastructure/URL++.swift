//
//  URLExtension.swift
//  MP3Book
//
//  Created by Dittner on 25/05/2019.
//

import Foundation
extension URL {
    func isMP3() -> Bool {
        return pathExtension.lowercased() == "mp3"
    }
    
    func fileExists() -> Bool {
        return FileManager.default.fileExists(atPath: self.path)
    }
    
    func isIPodItemLink() -> Bool {
        let iPodPrefix = "ipod-library"
        if description.count > iPodPrefix.count {
            let res = description.lowercased().prefix(iPodPrefix.count)
            return res == iPodPrefix
        }
        return false
    }    
}
