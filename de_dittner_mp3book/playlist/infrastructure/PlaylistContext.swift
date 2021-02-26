//
//  LibraryContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class PlaylistContext {
    static var shared: PlaylistContext = PlaylistContext()
    let bookRepository: IBookRepository
    let addBooksToPlaylistDomainService: AddBooksToPlaylistDomainService
    let playerAppService: PlayerAppService

    let dispatcher: PlaylistDispatcher
    let playlistBooksPort: OutputPort<Book>

    init() {
        logInfo(msg: "PlaylistContext initialized")
        dispatcher = PlaylistDispatcher()

        let storageURL = URLS.libraryURL.appendingPathComponent("Storage/book")
        let audioFileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)

        bookRepository = try! JSONBookRepository(serializer: bookSerializer, dispatcher: dispatcher, storeTo: storageURL)
        addBooksToPlaylistDomainService = AddBooksToPlaylistDomainService(repo: bookRepository)

        playerAppService = PlayerAppService(api: MediaAPI())

        playlistBooksPort = OutputPort<Book>()

        listenToPlaylistBooks()
    }

    private var disposeBag: Set<AnyCancellable> = []
    private func listenToPlaylistBooks() {
        bookRepository.subject
            .dropFirst()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { books in
                self.playlistBooksPort.write(books.filter { $0.addedToPlaylist })
            }
            .store(in: &disposeBag)

        dispatcher.subject
            .dropFirst()
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .sink { event in
                switch event {
                case .bookToPlaylistAdded, .bookFromPlaylistRemoved:
                    self.playlistBooksPort.write(self.bookRepository.subject.value.filter { $0.addedToPlaylist })
                default:
                    break
                }
            }
            .store(in: &disposeBag)
    }

    func notifyBookIsDamaged(_ b: Book) {
        let validationService = ValidationDomainService()

        switch validationService.validate(b: b) {
        case .bookNotFound:
            if b.source == .documents {
                AlertBox.shared.show(title: "NoBookInTheAppData", details: "CheckBookFolder \(b.folderPath!)")
            } else {
                AlertBox.shared.show(title: "NoBookInTheMediaLib", details: "CheckPlaylist \(b.title)")
            }
        case .fileNotFound:
            guard let f = b.audioFileColl.curFile else { return }
            if b.source == .documents {
                AlertBox.shared.show(title: "NoAudioFile", details: "CheckFileExistInAppData \(f.name)")
            } else {
                AlertBox.shared.show(title: "NoAudioFile", details: "CheckFileExistInMediaLib \(b.title) \(f.name)")
            }
        default: break
        }
    }

    func recoverBook(_ b: Book) {
        let validationService = ValidationDomainService()
        let reloadFilesService = SharedContext.shared.reloadAudioFilesFromIPodLibraryService

        let result = validationService.validate(b: b)
        switch result {
        case .ok:
            b.isDamaged = false
        case .bookNotFound:
            b.isDamaged = true
            notifyBookIsDamaged(b)
        case .fileNotFound:
            if b.source == .iPodLibrary {
                reloadFilesService.run(b)
                if !b.destroyed {
                    notifyBookIsDamaged(b)
                }
            } else {
                b.isDamaged = true
                notifyBookIsDamaged(b)
            }
        }
    }
}
