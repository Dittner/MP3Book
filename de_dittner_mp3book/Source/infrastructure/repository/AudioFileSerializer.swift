//
//  AudioFileSerializer.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation

enum AudioFileSerializerError: DetailedError {
    case propertyNotFound(name: String, fileId: ID)
}

class AudioFileSerializer: IAudioFileSerializer {
    let dispatcher: PlaylistDispatcher

    init(dispatcher: PlaylistDispatcher) {
        self.dispatcher = dispatcher
    }

    func serialize(_ f: AudioFile) -> [String: Any] {
        var dict = [String: Any]()
        dict["uid"] = f.uid
        dict["id"] = f.id
        dict["name"] = f.name
        dict["index"] = f.index
        dict["duration"] = f.duration
        dict["source"] = f.source.rawValue
        dict["path"] = f.path
        dict["playlistID"] = f.playlistID

        return dict
    }

    func deserialize(data: [String: Any]) throws -> AudioFile {
        var res: AudioFile
        guard let id = data["id"] as? ID, id.count > 0 else { throw AudioFileSerializerError.propertyNotFound(name: "id", fileId: "") }
        guard let uid = data["uid"] as? UID else { throw AudioFileSerializerError.propertyNotFound(name: "uid", fileId: id) }
        guard let name = data["name"] as? String, name.count > 0 else { throw AudioFileSerializerError.propertyNotFound(name: "name", fileId: id) }
        guard let index = data["index"] as? Int else { throw AudioFileSerializerError.propertyNotFound(name: "index", fileId: id) }
        guard let duration = data["duration"] as? Int else { throw AudioFileSerializerError.propertyNotFound(name: "duration", fileId: id) }
        guard let sourceInt = data["source"] as? Int, let source = AudioFileSource(rawValue: sourceInt) else { throw AudioFileSerializerError.propertyNotFound(name: "source", fileId: id) }

        if source == .documents {
            guard let path = data["path"] as? String, path.count > 0 else { throw AudioFileSerializerError.propertyNotFound(name: "path", fileId: id) }
            res = AudioFile(uid: uid, id: id, name: name, source: source, path: path, duration: duration, index: index, dispatcher: dispatcher)
        } else {
            guard let playlistID = data["playlistID"] as? UInt64 else { throw AudioFileSerializerError.propertyNotFound(name: "playlistID", fileId: id) }
            res = AudioFile(uid: uid, id: id, name: name, source: source, playlistID: playlistID, duration: duration, index: index, dispatcher: dispatcher)
        }

        return res
    }
}
