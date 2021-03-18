//
//  AudioFileSerializer.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation

enum AudioFileSerializerError: DetailedError {
    case invalidAudioFileDTO(details: String)
}

struct AudioFileDTO: Codable {
    var uid: UID
    var id: ID
    var name: String
    var index: Int
    var duration: Int
    var source: AudioFileSource
    var path: String?
    var playlistID: UInt64?
}

class AudioFileSerializer {
    let dispatcher: PlaylistDispatcher

    init(dispatcher: PlaylistDispatcher) {
        self.dispatcher = dispatcher
    }

    func serialize(_ f: AudioFile) -> AudioFileDTO {
        return AudioFileDTO(uid: f.uid,
                            id: f.id,
                            name: f.name,
                            index: f.index,
                            duration: f.duration,
                            source: f.source,
                            path: f.path,
                            playlistID: f.playlistID)
    }

    func deserialize(dto: AudioFileDTO) throws -> AudioFile {
        var file: AudioFile

        if let path = dto.path {
            file = AudioFile(uid: dto.uid,
                             id: dto.id,
                             name: dto.name,
                             path: path,
                             duration: dto.duration,
                             index: dto.index,
                             dispatcher: dispatcher)
        } else if let playlistID = dto.playlistID {
            file = AudioFile(uid: dto.uid,
                             id: dto.id,
                             name: dto.name,
                             playlistID: playlistID,
                             duration: dto.duration,
                             index: dto.index,
                             dispatcher: dispatcher)
        } else {
            throw AudioFileSerializerError.invalidAudioFileDTO(details: "AudioFile with id = \(dto.id) has nil path and nil playlistID")
        }

        return file
    }
}
