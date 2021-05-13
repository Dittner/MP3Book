// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
    func generateScreenshotsLane() {
        let devices = ["iPhone 11 Pro Max", "iPhone 8 Plus", "iPad Pro (12.9-inch) (4th generation)"]
        let languages = ["en-US", "ru", "de-DE"]

        snapshot(
            project: project,
            devices: devices,
            languages: languages,
            outputDirectory: "fastlane/screenshots/light",
            outputSimulatorLogs: true,
            clearPreviousScreenshots: true,
            reinstallApp: true,
            eraseSimulator: true,
            darkMode: false,
            appIdentifier: appIdentifier,
            clean: true,
            configuration: "Test",
            scheme: scheme,
            stopAfterFirstError: true
        )

        snapshot(
            project: project,
            devices: devices,
            languages: languages,
            outputDirectory: "fastlane/screenshots/dark",
            outputSimulatorLogs: true,
            clearPreviousScreenshots: false,
            reinstallApp: false,
            eraseSimulator: false,
            darkMode: true,
            appIdentifier: appIdentifier,
            clean: false,
            configuration: "Test",
            scheme: scheme,
            stopAfterFirstError: true
        )
    }

    func mergeScreenshotsLane() {
        let root = "fastlane/actions/merge_screenshots/config/"
        let configs: [String] = ["iPhone8-config.yml", "iPhone11-config.yml", "iPadPro2gen-config.yml", "iPadPro4gen-config.yml"]

        for configPath in configs {
            let command = RubyCommand(commandID: "", methodName: "merge_screenshots", className: nil, args: [RubyCommand.Argument(name: "config", value: root + configPath)])
            _ = runner.executeCommand(command)
        }
    }

    func uploadScreenshotsLane() {
        desc("Upload only screenshotsLane to AppStore")
        uploadToAppStore(username: appleID,
                         skipBinaryUpload: true,
                         skipMetadata: true,
                         force: true, // skip html review
                         overwriteScreenshots: true,
                         ignoreLanguageDirectoryValidation: true,
                         app: appIdentifier)
    }

    //
    // Uploading to TestFlight
    // fastlane beta appVersion:3.2.13
    // fastlane beta bumpType:major
    // fastlane beta bumpType:minor
    // fastlane beta bumpType:patch
    //
    func betaLane(withOptions options: [String: String]?) {
        let appVersion = options?["appVersion"]
        let bumpTypeOptional = options?["bumpType"]
        let bumpType = bumpTypeOptional ?? "patch"

        if appVersion != nil, bumpTypeOptional != nil {
            echo(message: "Only one parameter can be used: appVersion or bumpType")
            return
        }

        if !["major", "minor", "patch"].contains(bumpType) {
            echo(message: "Unknown parameter value \(bumpType)")
            return
        }

        desc("Upload a new beta build to TestFlight")
        incrementBuildNumber(xcodeproj: project)
        incrementVersionNumber(bumpType: bumpType, versionNumber: appVersion, xcodeproj: project)
        buildApp(project: project, scheme: scheme, includeBitcode: true)
        uploadToTestflight(username: appleID, teamId: teamID)
    }

    // To download metadata/screenshots from appStoreConnect use cmd:
    // $ fastlane deliver download_metadata --app_version 1.3
    // $ fastlane deliver download_screenshots --app_version 1.3
    // $ fastlane deliver download_screenshots --use_live_version true

    func releaseLane() {
        desc("Upload a new release build to AppStore")
        incrementBuildNumber(xcodeproj: project)
        buildApp(project: project, scheme: scheme, includeBitcode: true)
        uploadToAppStore(username: appleID,
                         appIdentifier: appIdentifier,
                         skipBinaryUpload: false,
                         skipScreenshots: true,
                         skipMetadata: true,
                         force: true, // skip html review
                         overwriteScreenshots: false,
                         submitForReview: false,
                         rejectIfPossible: true,
                         automaticRelease: true,
                         resetRatings: false,
                         teamId: teamID,
                         app: appIdentifier)
    }
}
