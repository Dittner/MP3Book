//
//  IPodService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Foundation
import MediaPlayer

class IPodAppService {
    public func readPlaylists() -> [Folder] {
        if let hasAccess = hasAccessToMediaLibrary() {
            return hasAccess ? fetchPlaylists() : []
        } else {
            return []
        }
    }

    private func hasAccessToMediaLibrary() -> Bool? {
        var hasAccess: Bool?
        let status = MPMediaLibrary.authorizationStatus()

        switch status {
        case .authorized, .restricted:
            hasAccess = true
        case .notDetermined:
            hasAccess = nil
        case .denied:
            hasAccess = false
            logWarn(msg: "IPodLibrary.hasAccessToMediaLibrary denied")
        default:
            hasAccess = false
            logWarn(msg: "IPodLibrary.hasAccessToMediaLibrary failed: Unknown MPMediaLibrary status: \(status)")
        }
        return hasAccess
    }

    private func requestAccessToMediaLibrary(_ handler: @escaping (MPMediaLibraryAuthorizationStatus) -> Void) {
        MPMediaLibrary.requestAuthorization(handler)
    }

    private func fetchPlaylists() -> [Folder] {
        var res: [Folder] = []

        let playlistQuery = MPMediaQuery.playlists()
        let playlists = playlistQuery.collections
        for playlist in playlists! {
            if let folder = playlistToFolder(playlist) {
                res.append(folder)
            }
        }
        return res.sorted(by: { $0 < $1 })
    }

    private func playlistToFolder(_ playlist: MPMediaItemCollection) -> Folder? {
        var files: [File] = []
        var totalDuration: Int = 0
        for item in playlist.items {
            if item.mediaType == .music {
                let file = File(mediaItem: item)
                totalDuration += Int(item.playbackDuration)
                files.append(file)
            }
        }

        if files.count > 0 {
            let title = playlist.value(forProperty: MPMediaPlaylistPropertyName) as! String
            let folder = Folder(playlistPersistentID: playlist.persistentID, title: title, totalDuration: totalDuration, files: files, depth: 0)

            return folder
        }
        return nil
    }

    private func getPlaylist(persistentID id: UInt64) -> Folder? {
        guard let hasAccess = hasAccessToMediaLibrary() else { return nil }
        guard hasAccess else { return nil }

        let filter = MPMediaPropertyPredicate(value: id,
                                                 forProperty: MPMediaItemPropertyPersistentID)
        let playlistQuery = MPMediaQuery.playlists()
        playlistQuery.addFilterPredicate(filter)
        let playlists = playlistQuery.collections

        let firstFoundPlaylist = playlists != nil && playlists!.count > 0 ? playlists![0] : nil
        guard let playlist = firstFoundPlaylist else { return nil }

        return playlistToFolder(playlist)
    }
}
