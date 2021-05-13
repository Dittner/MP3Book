//
//  SharedContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation
import UIKit

protocol MP3BookContextProtocol {
    var ui: MP3BookContext.UI { get }
    var app: MP3BookContext.APP { get }
    var domain: MP3BookContext.Domain { get }
}

class MP3BookContext: MP3BookContextProtocol {
    lazy var domain = configDomainLayer()
    lazy var app = configAppLayer(context: self)
    lazy var ui = configUILayer(context: self)

    init() {
        logInfo(msg: "MP3BookContext is initialized")
    }

    private func configDomainLayer() -> MP3BookContext.Domain {
        let dispatcher = PlaylistDispatcher()

        let storageURL = URLS.libraryURL.appendingPathComponent("Storage/book")
        let bookSerializer = BookSerializer(dispatcher: dispatcher)
        let bookRepository = JSONBookRepository(serializer: bookSerializer, dispatcher: dispatcher, storeTo: storageURL)

        let folderToBook = FolderToBookMapper(repo: bookRepository, dispatcher: dispatcher)
        let playlistToBook = PlaylistToBookMapper(repo: bookRepository, dispatcher: dispatcher)
        let bookFactory = BookFactory(repo: bookRepository, folderToBook: folderToBook, playlistToBook: playlistToBook)

        return MP3BookContext.Domain(bookRepository: bookRepository,
                                     bookFactory: bookFactory,
                                     dispatcher: dispatcher)
    }

    private func configAppLayer(context: MP3BookContextProtocol) -> MP3BookContext.APP {
        let documentsService = DocumentsAppService()
        let iPodService = IPodAppService()
        let playerService = PlayerAppService(api: MediaAPI(), context: context)

        let playlistToBook = PlaylistToBookMapper(repo: context.domain.bookRepository,
                                                  dispatcher: context.domain.dispatcher)

        let reloadFilesService = ReloadAudioFilesFromIPodLibraryService(playlistToBookMapper: playlistToBook,
                                                                        iPodAppService: iPodService, bookRepo: context.domain.bookRepository)

        let demoFileService = DemoFileAppService(bookRepository: context.domain.bookRepository,
                                                 documentsAppService: documentsService,
                                                 dispatcher: context.domain.dispatcher)

        let ab = AlertBox()

        let persistenceService = PersistenceValidationAppService(iPodAppService: iPodService,
                                                                 reloadFilesService: reloadFilesService,
                                                                 alertBox: ab)

        return MP3BookContext.APP(documentsService: documentsService,
                                  iPodService: iPodService,
                                  playerService: playerService,
                                  reloadFilesService: reloadFilesService,
                                  demoFileService: demoFileService,
                                  persistenceValidationService: persistenceService,
                                  alertBox: ab)
    }

    private func configUILayer(context: MP3BookContextProtocol) -> MP3BookContext.UI {
        return MP3BookContext.UI(navigator: Navigator(),
                                 themeManager: ThemeManager(),
                                 systemVolume: SystemVolume(),
                                 viewModels: UI.VM(context: context))
    }
}

extension MP3BookContext {
    class Domain {
        let bookRepository: IBookRepository
        let bookFactory: BookFactory
        let dispatcher: PlaylistDispatcher

        init(bookRepository: IBookRepository, bookFactory: BookFactory, dispatcher: PlaylistDispatcher) {
            self.bookRepository = bookRepository
            self.bookFactory = bookFactory
            self.dispatcher = dispatcher
        }
    }
}

extension MP3BookContext {
    class UI {
        let navigator: Navigator
        let themeManager: ThemeManager
        let systemVolume: SystemVolume
        let viewModels: VM

        init(navigator: Navigator, themeManager: ThemeManager, systemVolume: SystemVolume, viewModels: VM) {
            self.navigator = navigator
            self.themeManager = themeManager
            self.systemVolume = systemVolume
            self.viewModels = viewModels
        }
    }
}

extension MP3BookContext.UI {
    class VM {
        private let context: MP3BookContextProtocol

        lazy var bookListVM = BookListVM(context: context)
        lazy var fileListVM = AudioFileListVM(context: context)
        lazy var libraryVM = LibraryVM(context: context)
        lazy var manualVM = ManualVM(context: context)

        init(context: MP3BookContextProtocol) {
            self.context = context
        }
    }
}

extension MP3BookContext {
    class APP {
        let documentsService: IDocumentsAppService
        let iPodService: IPodAppService
        let playerService: PlayerAppService
        let reloadAudioFilesFromIPodLibraryService: ReloadAudioFilesFromIPodLibraryService
        let demoFileService: DemoFileAppService
        let persistenceValidationService: PersistenceValidationAppService
        let alertBox: AlertBox

        init(documentsService: IDocumentsAppService,
             iPodService: IPodAppService,
             playerService: PlayerAppService,
             reloadFilesService: ReloadAudioFilesFromIPodLibraryService,
             demoFileService: DemoFileAppService,
             persistenceValidationService: PersistenceValidationAppService,
             alertBox: AlertBox) {
            self.documentsService = documentsService
            self.iPodService = iPodService
            self.playerService = playerService
            reloadAudioFilesFromIPodLibraryService = reloadFilesService
            self.demoFileService = demoFileService
            self.persistenceValidationService = persistenceValidationService
            self.alertBox = alertBox
        }
    }
}

class StubMP3BookContext: MP3BookContextProtocol {
    lazy var domain = configDomainLayer()
    lazy var app = configAppLayer(context: self)
    lazy var ui = configUILayer(context: self)

    init() {
        logInfo(msg: "Stub MP3BookContext fot UITesting is initialized")
    }

    private func configDomainLayer() -> MP3BookContext.Domain {
        let dispatcher = PlaylistDispatcher()
        let stubDocsService = UITestDocumentsAppService()
        let stubRepo = UITestBookRepository(dispatcher: dispatcher)
        let folders = stubDocsService.createTestContent().folders
        let books = FolderToBookMapper(repo: stubRepo, dispatcher: dispatcher).convert(from: folders)
        stubRepo.write(books)

        let folderToBook = FolderToBookMapper(repo: stubRepo, dispatcher: dispatcher)
        let playlistToBook = PlaylistToBookMapper(repo: stubRepo, dispatcher: dispatcher)
        let bookFactory = BookFactory(repo: stubRepo, folderToBook: folderToBook, playlistToBook: playlistToBook)

        return MP3BookContext.Domain(bookRepository: stubRepo,
                                     bookFactory: bookFactory,
                                     dispatcher: dispatcher)
    }

    private func configAppLayer(context: MP3BookContextProtocol) -> MP3BookContext.APP {
        let stubDocumentsService = UITestDocumentsAppService()
        let iPodService = IPodAppService()
        let playerService = PlayerAppService(api: MediaAPI(), context: context)

        let playlistToBook = PlaylistToBookMapper(repo: context.domain.bookRepository,
                                                  dispatcher: context.domain.dispatcher)

        let reloadFilesService = ReloadAudioFilesFromIPodLibraryService(playlistToBookMapper: playlistToBook,
                                                                        iPodAppService: iPodService, bookRepo: context.domain.bookRepository)

        let demoFileService = DemoFileAppService(bookRepository: context.domain.bookRepository,
                                                 documentsAppService: stubDocumentsService,
                                                 dispatcher: context.domain.dispatcher)

        let ab = AlertBox()

        let persistenceService = PersistenceValidationAppService(iPodAppService: iPodService,
                                                                 reloadFilesService: reloadFilesService,
                                                                 alertBox: ab)

        return MP3BookContext.APP(documentsService: stubDocumentsService,
                                  iPodService: iPodService,
                                  playerService: playerService,
                                  reloadFilesService: reloadFilesService,
                                  demoFileService: demoFileService,
                                  persistenceValidationService: persistenceService,
                                  alertBox: ab)
    }

    private func configUILayer(context: MP3BookContextProtocol) -> MP3BookContext.UI {
        return MP3BookContext.UI(navigator: Navigator(),
                                 themeManager: ThemeManager(),
                                 systemVolume: SystemVolume(),
                                 viewModels: MP3BookContext.UI.VM(context: context))
    }
}
