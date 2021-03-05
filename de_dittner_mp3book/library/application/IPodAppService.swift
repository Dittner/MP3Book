//
//  IPodService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import Foundation
import MediaPlayer

class IPodAppService {
    public func read(_ complete: @escaping ([Playlist]) -> Void) {
        let needRequestToMediaLibrary = !UIDevice.current.isSimulator && hasAccessToMediaLibrary() == nil
        if needRequestToMediaLibrary {
            logInfo(msg: "IPodLibrary.requestAccessToMediaLibrary")
            requestAccessToMediaLibrary { result in
                if result == .authorized || result == .restricted {
                    DispatchQueue.main.async {
                        complete(self.fetchPlaylists())
                    }
                }
            }
        } else {
            if let hasAccess = hasAccessToMediaLibrary() {
                complete(hasAccess ? fetchPlaylists() : [])
            } else {
                complete([])
            }
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
            logWarn(msg: "IPodLibrary.hasAccessToMediaLibrary notDetermined")
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

    private func fetchPlaylists() -> [Playlist] {
        var res: [Playlist] = []

        let playlistQuery = MPMediaQuery.playlists()
        let playlistColl = playlistQuery.collections
        for playlistItem in playlistColl! {
            if let playlist = createPlaylist(playlistItem) {
                res.append(playlist)
            }
        }
        return res
    }

    private func createPlaylist(_ playlist: MPMediaItemCollection) -> Playlist? {
        var files: [PlaylistFile] = []
        var totalDuration: Int = 0
        for item in playlist.items where item.mediaType == .music {
            let file = PlaylistFile(mediaItem: item)
            totalDuration += Int(item.playbackDuration)
            files.append(file)
        }

        if files.count > 0 {
            let title = playlist.value(forProperty: MPMediaPlaylistPropertyName) as? String ?? "No name"
            let res = Playlist(playlistPersistentID: playlist.persistentID, title: title, totalDuration: totalDuration, files: files)

            return res
        }
        return nil
    }

    func getPlaylist(persistentID id: UInt64) -> Playlist? {
        guard let hasAccess = hasAccessToMediaLibrary(), hasAccess else { return nil }

        let filter = MPMediaPropertyPredicate(value: id,
                                              forProperty: MPMediaItemPropertyPersistentID)
        let playlistQuery = MPMediaQuery.playlists()
        playlistQuery.addFilterPredicate(filter)
        let playlistColl = playlistQuery.collections

        let firstFoundPlaylistItem = playlistColl != nil && playlistColl!.count > 0 ? playlistColl![0] : nil
        guard let playlistItem = firstFoundPlaylistItem else { return nil }

        return createPlaylist(playlistItem)
    }

    func playlistExists(persistentID id: UInt64) -> Bool {
        guard let hasAccess = hasAccessToMediaLibrary(), hasAccess else { return false }

        let filter = MPMediaPropertyPredicate(value: id,
                                              forProperty: MPMediaItemPropertyPersistentID)
        let playlistQuery = MPMediaQuery.playlists()
        playlistQuery.addFilterPredicate(filter)
        let playlistColl = playlistQuery.collections

        let firstFoundPlaylistItem = playlistColl != nil && playlistColl!.count > 0 ? playlistColl![0] : nil
        return firstFoundPlaylistItem != nil
    }
}
