//
//  SystemVolume.swift
//  MP3Book
//
//  Created by Alexander Dittner on 17.02.2021.
//

import MediaPlayer
import SwiftUI

class SystemVolume: ObservableObject {
    @Published var value: Int

    static var shared: SystemVolume = SystemVolume()

    init() {
        value = Int(AVAudioSession.sharedInstance().outputVolume * 100)

        NotificationCenter.default.addObserver(self, selector: Selector(("volumeDidChange:")), name: NSNotification.Name(rawValue: "AVSystemController_SystemVolumeDidChangeNotification"), object: nil)

        subscribe()
    }

    private let session = AVAudioSession.sharedInstance()
    private var progressObserver: NSKeyValueObservation!

    func subscribe() {
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print("cannot activate session")
        }

        progressObserver = session.observe(\.outputVolume) { [self] session, _ in
            DispatchQueue.main.async {
                self.value = Int(session.outputVolume * 100)
            }
        }
    }
}
