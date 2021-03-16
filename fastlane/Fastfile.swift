// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    func takeScreenshotsLane() {
        snapshot(
            project: "MP3Book.xcodeproj",
            //devices: ["iPhone 11 Pro Max"],
            devices: ["iPhone 11 Pro Max", "iPad Pro (12.9-inch) (4th generation)"],
            languages: ["ru-RU", "de-DE"],
            //languages: ["ru-RU"],
            outputDirectory: "screenshots",
            outputSimulatorLogs: true,
            clearPreviousScreenshots: true,
            reinstallApp: true,
            eraseSimulator: true,
            darkMode: false,
            appIdentifier: "de.dittner.mp3book",
            clean: true,
            configuration: "Test",
            scheme: "MP3Book",
            stopAfterFirstError: true
        )
    }

//    func uploadScreenshotsLane() {
//        desc("Generate new localized screenshots")
//        uploadToAppStore(username: "alexander.dittner@icloud.com", app: "de.dittner.mp3book", skipBinaryUpload: true, skipMetadata: true)
//    }
}
