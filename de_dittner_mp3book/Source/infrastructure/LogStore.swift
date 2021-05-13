//
//  LoggingConfiguration.swift
//  MP3Book
//
//  Created by Dittner on 17/08/2019.
//

import Foundation
import UIKit
import os.log

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "m3b")

func logInfo(msg: String) {
    logger.info("\(msg)")
}

func logWarn(msg: String) {
    logger.warning("\(msg)")
}

func logErr(msg: String) {
    logger.error("\(msg)")
}

func logAbout() {
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
