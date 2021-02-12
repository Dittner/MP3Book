//
//  AudioFileSerializer.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation

enum AudioFileSerializerError: DetailedError {
    case propertyNotFound(name:String, fileId: ID)
}

class AudioFileSerializer:IAudioFileSerializer {

    func serialize(_ f: AudioFile) -> [String : Any] {
        var dict = [String : Any]()
        dict["id"] = f.id
        dict["name"] = f.name
        dict["index"] = f.index
        dict["duration"] = f.duration
        dict["source"] = f.source.rawValue
        dict["url"] = f.url.absoluteString
        
        return dict
    }
    
    func deserialize(data: [String : Any]) throws -> AudioFile {
        guard let id = data["id"] as? ID, id.count > 0 else {throw AudioFileSerializerError.propertyNotFound(name: "id", fileId: "") }
        guard let name = data["name"] as? String, name.count > 0 else {throw AudioFileSerializerError.propertyNotFound(name: "name", fileId: id) }
        guard let index = data["index"] as? Int else {throw AudioFileSerializerError.propertyNotFound(name: "index", fileId: id) }
        guard let duration = data["duration"] as? Int else {throw AudioFileSerializerError.propertyNotFound(name: "duration", fileId: id) }
        guard let sourceInt = data["source"] as? Int, let source = AudioFileSource(rawValue: sourceInt) else {throw AudioFileSerializerError.propertyNotFound(name: "source", fileId: id) }
        guard let urlStr = data["url"] as? String, urlStr.count > 0, let url = URL(string: urlStr) else {throw AudioFileSerializerError.propertyNotFound(name: "url",  fileId: id) }
        
        return AudioFile(id: id, name: name, source: source, url: url, duration: duration, index: index)
    }
}
