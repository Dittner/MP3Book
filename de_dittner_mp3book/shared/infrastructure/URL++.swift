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
    
    func isIpodItemLink() -> Bool {
        let ipodPrefix = "ipod-library"
        if description.count > ipodPrefix.count {
            let res = description.lowercased().prefix(ipodPrefix.count)
            return res == ipodPrefix
        }
        return false
    }
}
