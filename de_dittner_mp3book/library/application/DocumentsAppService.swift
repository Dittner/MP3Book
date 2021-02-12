//
//  ReadDocumentsContentAppService.swift
//  MP3Book
//
//  Created by Alexander Dittner on 05.02.2021.
//

import AVFoundation
import Foundation

enum DocumentsAppServiceError: DetailedError {
    case readMP3ContentFailed(details: String, mp3FileURL:String)
    case getFileUrlsFailed(details: String)
}

struct DocumentsContent {
    var folders: [Folder]
    var files: [FolderFile]
    var totalDuration: Int
}

class DocumentsAppService {
    func read() throws -> DocumentsContent {
        return try readFrom(dirUrl: URLS.documentsURL)
    }

    func readFrom(dirUrl: URL, title: String? = nil, parentFolderName: String? = nil, depth: Int = 0) throws -> DocumentsContent {
        var files: [FolderFile] = []
        var folders: [Folder] = []
        var totalDuration: Int = 0
        let fileManager = FileManager.default

        do {
            let urls = try fileManager.contentsOfDirectory(at: dirUrl, includingPropertiesForKeys: nil)

            for url: URL in urls {
                do {
                    let attributes: URLResourceValues = try url.resourceValues(forKeys: [.isDirectoryKey, .nameKey])

                    if attributes.isDirectory! {
                        let subfolderTitle = attributes.name != nil ? attributes.name! : "No name"
                        let subFolderContent: DocumentsContent = try readFrom(dirUrl: url, title: subfolderTitle, parentFolderName: title, depth: depth + 1)
                        folders += subFolderContent.folders
                        files += subFolderContent.files
                        totalDuration += subFolderContent.totalDuration
                    } else if title != nil && url.isMP3() {
                        let mp3File = AVAsset(url: url)
                        let path = urlToRelativePathFromDocuments(url)
                        let fileName: String = title != nil ? title! + "/" + attributes.name! : attributes.name!
                        let duration: Int = Int(mp3File.duration.seconds.rounded(.up))
                        let f: FolderFile = FolderFile(filePath: path, name: fileName, duration: duration)
                        totalDuration += f.duration
                        files.append(f)
                    }
                } catch {
                    throw DocumentsAppServiceError.readMP3ContentFailed(details: error.localizedDescription, mp3FileURL: url.description)
                }
            }
        } catch {
            throw DocumentsAppServiceError.getFileUrlsFailed(details: "\(dirUrl.path), \(error.localizedDescription)")
        }

        if title != nil && files.count > 0 {
            let path = urlToRelativePathFromDocuments(dirUrl)
            let f = Folder(folderPath: path, title: title!, parentFolderName: parentFolderName, totalDuration: totalDuration, files: files, depth: depth)
            folders.insert(f, at: 0)
        }
        return DocumentsContent(folders: folders, files: files, totalDuration: totalDuration)
    }

    let rootFolder = "/Documents/"
    private func urlToRelativePathFromDocuments(_ u: URL) -> String {
        let p = u.path

        let rootFolderInd = p.range(of: rootFolder, options: NSString.CompareOptions.literal, range: p.startIndex ..< p.endIndex, locale: nil)

        if let ind = rootFolderInd {
            let range = p.index(ind.lowerBound, offsetBy: rootFolder.count) ..< p.endIndex
            return String(p[range])
        } else {
            return p
        }
    }
}
