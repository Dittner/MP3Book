//
//  PlaylistDomainEntity.swift
//  MP3Book
//
//  Created by Alexander Dittner on 14.02.2021.
//

import Foundation

class PlaylistDomainEntity {
    let dispatcher: PlaylistDispatcher
    init(dispatcher: PlaylistDispatcher) {
        self.dispatcher = dispatcher
    }
}
