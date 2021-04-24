// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    let devices = ["iPhone 11 Pro Max", "iPhone 8 Plus", "iPad Pro (12.9-inch) (4th generation)"]
    let languages = ["en-EN", "ru-RU", "de-DE"]
    let bundleID = "de.dittner.mp3book"

    func generateScreenshotsLane() {
        snapshot(
            project: "MP3Book.xcodeproj",
            // devices: ["iPhone 11 Pro Max"],
            // languages: ["ru-RU"],
            devices: devices,
            languages: languages,
            outputDirectory: "screenshots/light",
            outputSimulatorLogs: true,
            clearPreviousScreenshots: true,
            reinstallApp: true,
            eraseSimulator: true,
            darkMode: false,
            appIdentifier: bundleID,
            clean: true,
            configuration: "Test",
            scheme: "MP3Book",
            stopAfterFirstError: true
        )

        snapshot(
            project: "MP3Book.xcodeproj",
            // devices: ["iPhone 11 Pro Max"],
            // languages: ["ru-RU"],
            devices: devices,
            languages: languages,
            outputDirectory: "screenshots/dark",
            outputSimulatorLogs: true,
            clearPreviousScreenshots: false,
            reinstallApp: false,
            eraseSimulator: false,
            darkMode: true,
            appIdentifier: bundleID,
            clean: false,
            configuration: "Test",
            scheme: "MP3Book",
            stopAfterFirstError: true
        )
    }

//    func uploadScreenshotsLane() {
//        desc("Generate new localized screenshots")
//        uploadToAppStore(username: "alexander.dittner@icloud.com", app: "de.dittner.mp3book", skipBinaryUpload: true, skipMetadata: true)
//    }

    func mergeScreenshotsLane() {
        let root = "fastlane/actions/merge_screenshots/config/"
        let configs: [String] = ["iPhone8-config.yml", "iPhone11-config.yml", "iPadPro-config.yml"]
        
        for configPath in configs {
            let command = RubyCommand(commandID: "", methodName: "merge_screenshots", className: nil, args: [RubyCommand.Argument(name: "config", value: root + configPath)])
            _ = runner.executeCommand(command)
        }
    }
}
