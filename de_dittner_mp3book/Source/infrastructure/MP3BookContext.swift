//
//  SharedContext.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation
import UIKit

class MP3BookContext {
    static var shared: MP3BookContext = MP3BookContext()
    let documentsAppService: DocumentsAppServiceProtocol
    let iPodAppService: IPodAppService

    let bookRepository: IBookRepository
    let bookFactory: BookFactory
    let playerAppService: PlayerAppService

    let reloadAudioFilesFromIPodLibraryService: ReloadAudioFilesFromIPodLibraryService
    let dispatcher: PlaylistDispatcher

    init() {
        MP3BookContext.logAbout()
        logInfo(msg: "SharedContext initialized")

        dispatcher = PlaylistDispatcher()
        iPodAppService = IPodAppService()

        let storageURL = URLS.libraryURL.appendingPathComponent("Storage/book")
        let audioFileSerializer = AudioFileSerializer(dispatcher: dispatcher)
        let bookSerializer = BookSerializer(fileSerializer: audioFileSerializer, dispatcher: dispatcher)

        #if UITESTING
            let uiTestingDocsService = UITestDocumentsAppService()
            let uiTestingRepo = UITestBookRepository(dispatcher: dispatcher)

            let folders = uiTestingDocsService.createTestContent().folders
            let books = FolderToBookMapper(repo: uiTestingRepo, dispatcher: dispatcher).convert(from: folders)
            try? uiTestingRepo.write(books)

            documentsAppService = uiTestingDocsService
            bookRepository = uiTestingRepo

        #else
            documentsAppService = DocumentsAppService()
            bookRepository = JSONBookRepository(serializer: bookSerializer, dispatcher: dispatcher, storeTo: storageURL)

        #endif

        let folderToBook = FolderToBookMapper(repo: bookRepository, dispatcher: dispatcher)
        let playlistToBook = PlaylistToBookMapper(repo: bookRepository, dispatcher: dispatcher)
        bookFactory = BookFactory(repo: bookRepository, folderToBook: folderToBook, playlistToBook: playlistToBook)

        playerAppService = PlayerAppService(api: MediaAPI())

        reloadAudioFilesFromIPodLibraryService = ReloadAudioFilesFromIPodLibraryService(playlistToBookMapper: playlistToBook, iPodAppService: iPodAppService, bookRepo: bookRepository)
    }

    // call run to be sure SharedContext has been launched
    func run() {
        addDemoFilesIfNeeded()
        logInfo(msg: "App has 3 modules: SharedContext, LibraryContext, PlaylistContext")
    }

    private static func logAbout() {
        var aboutLog: String = "MP3BookLogs\n"
        let ver: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        aboutLog += "v." + ver + "." + build + "\n"

        let device = UIDevice.current
        let scaleFactor = UIScreen.main.scale
        let deviceSize = UIScreen.main.bounds

        aboutLog += "device: " + device.modelName + "\n"
        aboutLog += "os: " + device.systemName + " " + device.systemVersion + "\n"
        aboutLog += "device scaleFactor: \(scaleFactor)\n"
        aboutLog += "device size: \(Int(deviceSize.width * scaleFactor))/\(Int(deviceSize.height * scaleFactor))\n"
        aboutLog += "simulator: " + device.isSimulator.description + "\n"

        #if DEBUG
            aboutLog += "debug: true\n"
            aboutLog += "docs folder: \\" + URLS.documentsURL.description + "\n"
        #else
            aboutLog += "debug: false\n"
        #endif

        #if UITESTING
            aboutLog += "UITESTING: true\n"
        #else
            aboutLog += "UITESTING: false\n"
        #endif

        logInfo(msg: aboutLog)
    }

    private func addDemoFilesIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Constants.keys.demoFileShown) else { return }

        let demoBook = "Demo – Three Laws of Robotics"
        let service = DemoFileAppService()

        do {
            try service.copyDemoFile(srcFileName: demoBook, to: URLS.documentsURL)

            guard let docsContent = try? MP3BookContext.shared.documentsAppService.read() else { return }
            let folderToBook = FolderToBookMapper(repo: bookRepository, dispatcher: dispatcher)
            let books = folderToBook.convert(from: docsContent.folders)

            UserDefaults.standard.set(true, forKey: Constants.keys.demoFileShown)
            try bookRepository.write(books)

        } catch {
            logErr(msg: error.localizedDescription)
        }
    }

    func notifyBookIsDamaged(_ b: Book) {
        let validationService = PersistenceValidationDomainService()

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
        let validationService = PersistenceValidationDomainService()
        let reloadFilesService = MP3BookContext.shared.reloadAudioFilesFromIPodLibraryService

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
