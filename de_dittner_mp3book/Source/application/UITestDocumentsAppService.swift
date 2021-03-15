//
//  UITestDocumentsAppService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 16.03.2021.
//

import Combine
import Foundation

class UITestDocumentsAppService: DocumentsAppServiceProtocol {
    private let testBooks = ["George Orwell – 1984", "Sigmund Freud – Die Zukunft einer Illusion", "Достоевский – Записки из подполья"]

    func read() throws -> DocumentsContent {
        return createTestContent()
    }

    func createTestContent() -> DocumentsContent {
        var folders: [Folder] = []
        let fileDuration: Int = 1234

        let demoFolderName = "Demo – Three Laws of Robotics"
        let demoFileName = "\(demoFolderName)/1.mp3"
        let demoFile = FolderFile(filePath: demoFileName, name: demoFileName, duration: 45)
        let demoFolder = Folder(folderPath: demoFolderName, title: demoFolderName, parentFolderName: nil, totalDuration: 45, files: [demoFile], depth: 1)

        folders.append(demoFolder)

        for folderName in testBooks {
            var files: [FolderFile] = []
            for i in 1 ... folderName.count {
                let fileName = folderName + "/" + (i < 10 ? "0\(i).mp3" : "\(i).mp3")
                let testFile = FolderFile(filePath: fileName, name: fileName, duration: fileDuration)
                files.append(testFile)
            }
            folders.append(Folder(folderPath: folderName, title: folderName, parentFolderName: nil, totalDuration: files.count * fileDuration, files: files, depth: 1))
        }

        return DocumentsContent(folders: folders, files: [], totalDuration: 0)
    }
}
