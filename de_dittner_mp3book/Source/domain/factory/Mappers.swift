//
//  Mappers.swift
//  MP3Book
//
//  Created by Alexander Dittner on 15.03.2021.
//

protocol FolderToBookMapperProtocol {
    func convert(from: [Folder]) -> [Book]
}

protocol PlaylistToBookMapperProtocol {
    func convert(from: [Playlist]) -> [Book]
    func convert(_ files: [PlaylistFile]) -> [AudioFile]
}
