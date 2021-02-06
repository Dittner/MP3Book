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
    

    func copyDemoFileToDocumentsFolder(srcFileName:String, destFolderName:String) throws {
        // Move the folder with demo record from bundle to documents folder
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        let destDemoFolderURL = documentsURL.appendingPathComponent(destFolderName)
        let destDemoFileUrl = destDemoFolderURL.appendingPathComponent(srcFileName)

        if !((try? destDemoFileUrl.checkResourceIsReachable()) ?? false) {
            logger.info("Demo file is copied...")

            do {
                try FileManager.default.createDirectory(atPath: destDemoFolderURL.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                throw DemoFileIOError.demoFolderNotCreated(details: error.localizedDescription)
                // logger.info("Unable to create demo folder \(error.localizedDescription)")
            }

            let srcDemoFileURL = Bundle.main.resourceURL?.appendingPathComponent(srcFileName)

            let hasDemoFile = (try? srcDemoFileURL?.checkResourceIsReachable()) ?? false
            if !hasDemoFile {
                throw DemoFileIOError.demoFileNotFound(fileName: srcFileName)
            }

            do {
                try fileManager.copyItem(atPath: (srcDemoFileURL?.path)!, toPath: destDemoFileUrl.path)
            } catch let error as NSError {
                throw DemoFileIOError.demoFileNotCopied(details: error.description)
                // logger.info("Couldn't copy demo folder to documents folder! Error:\(error.description)")
            }

            logger.info("Demo file has been copied")
        }
    }
}
