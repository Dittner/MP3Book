//
//  RootVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 04.02.2021.
//

import Foundation
import UIKit

class Bootstrap {
    init() {
        logAbout()
        addDemoFileIfNeeded()
    }

    func logAbout() {
        var aboutLog: String = "MP3BookLogs\n"
        let ver: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0"
        let build: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "0"
        aboutLog += "v." + ver + "." + build + "\n"

        let device = UIDevice.current
        aboutLog += "simulator: " + device.isSimulator.description + "\n"
        aboutLog += "device: " + device.modelName + "\n"
        aboutLog += "os: " + device.systemName + " " + device.systemVersion + "\n"
        #if DEBUG
            aboutLog += "debug mode\n"
            aboutLog += "docs folder: \\" + device.documentsURL.description
        #else
            aboutLog += "release mode\n"
        #endif

        logInfo(msg: aboutLog)
    }

    func addDemoFileIfNeeded() {
        if !UserDefaults.standard.bool(forKey: "demoFileShown") {
            let service = DemoFileAppService()

            do {
                try service.copyDemoFileToDocumentsFolder(srcFileName: "record.mp3", destFolderName: "Demo – Three Laws of Robotics")
                UserDefaults.standard.set(true, forKey: "demoFileShown")
            } catch {
                logErr(msg: error.localizedDescription)
            }
        }
    }
}
