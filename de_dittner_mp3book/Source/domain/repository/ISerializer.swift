//
//  ISerializer.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation
protocol IBookSerializer {
    func serialize(_ b: Book) -> [String: Any]
    func deserialize(data: [String: Any]) throws -> Book
}

protocol IAudioFileSerializer {
    func serialize(_ f: AudioFile) -> [String: Any]
    func deserialize(data: [String: Any]) throws -> AudioFile
}
