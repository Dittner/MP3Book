//
//  LoggingConfiguration.swift
//  MP3Book
//
//  Created by Dittner on 17/08/2019.
//

import Foundation
import UIKit
import os.log

let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "main")

func logInfo(msg: String) {
    logger.info("\(msg)")
}

func logWarn(msg: String) {
    logger.warning("\(msg)")
}

func logErr(msg: String) {
    logger.error("\(msg)")
}
