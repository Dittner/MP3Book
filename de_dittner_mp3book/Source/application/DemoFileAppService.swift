//
//  DemoFile.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.01.2020.
//

import UIKit

enum DemoFileIOError: DetailedError {
    case demoFolderNotCreated(details: String)
    case demoFileNotFound(fileName: String)
    case demoFileNotCopied(details: String)
}

class DemoFileAppService {
    let bookRepository: IBookRepository
    let documentsAppService: IDocumentsAppService
    let dispatcher: PlaylistDispatcher

    init(bookRepository: IBookRepository, documentsAppService: IDocumentsAppService, dispatcher: PlaylistDispatcher) {
        self.bookRepository = bookRepository
        self.documentsAppService = documentsAppService
        self.dispatcher = dispatcher
    }

    func addDemoFilesIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: Constants.keys.demoFileShown) else { return }

        let demoBook = "Demo – Three Laws of Robotics"

        do {
            try copyDemoFile(srcFileName: demoBook, to: URLS.documentsURL)

            guard let docsContent = try? documentsAppService.read() else { return }
            let folderToBook = FolderToBookMapper(repo: bookRepository, dispatcher: dispatcher)
            let books = folderToBook.convert(from: docsContent.folders)

            UserDefaults.standard.set(true, forKey: Constants.keys.demoFileShown)
            try bookRepository.write(books)

        } catch {
            logErr(msg: error.localizedDescription)
        }
    }

    // Move the folder with demo record from bundle to documents (folder)
    func copyDemoFile(srcFileName: String, to: URL) throws {
        let destFolderURL = to
        let fileManager = FileManager.default
        let destDemoFileUrl = destFolderURL.appendingPathComponent(srcFileName)

        if !((try? destDemoFileUrl.checkResourceIsReachable()) ?? false) {
            logInfo(msg: "Demo file is copied...")

            do {
                try FileManager.default.createDirectory(atPath: destFolderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw DemoFileIOError.demoFolderNotCreated(details: error.localizedDescription)
            }

            let srcDemoFileURL = getFileUrl(fileName: srcFileName)
            if srcDemoFileURL == nil {
                throw DemoFileIOError.demoFileNotFound(fileName: srcFileName)
            }

            do {
                try fileManager.copyItem(atPath: (srcDemoFileURL?.path)!, toPath: destDemoFileUrl.path)
            } catch let error as NSError {
                throw DemoFileIOError.demoFileNotCopied(details: error.description)
            }

            logInfo(msg: "Demo file has been copied")
        }
    }

    private func getFileUrl(fileName: String) -> URL? {
        for b in Bundle.allBundles {
            if let url = b.resourceURL?.appendingPathComponent(fileName), (try? url.checkResourceIsReachable()) != nil {
                return url
            }
        }
        return nil
    }
}
