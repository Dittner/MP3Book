//
//  PlaylistDomainEventDispatcher.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Combine
import SwiftUI

protocol DomainEventDispatcher {
    associatedtype DomainEvent
    func notify(_ event: DomainEvent)
    var subject: PassthroughSubject<DomainEvent, Never> { get }
}

class PlaylistDispatcher: DomainEventDispatcher {
    typealias DomainEvent = PlaylistDomainEvent

    let subject = PassthroughSubject<DomainEvent, Never>()

    func notify(_ event: DomainEvent) {
        subject.send(event)
    }
}

enum PlaylistDomainEvent {
    case bookStateChanged(book: Book)
    case bookToPlaylistAdded(book: Book)
    case bookFromPlaylistRemoved(book: Book)
    case bookIsDamaged(book: Book)
    case audioFileStateChanged(file: AudioFile)
    case repositoryIsReady(repo: IBookRepository)
    case repositoryStoreComplete(repo: IBookRepository)
}
