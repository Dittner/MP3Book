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

    private let session = AVAudioSession.sharedInstance()
    private var progressObserver: NSKeyValueObservation!

    init() {
        value = Int(AVAudioSession.sharedInstance().outputVolume * 100)

        progressObserver = AVAudioSession.sharedInstance().observe(\.outputVolume) { [self] session, _ in
            DispatchQueue.main.async {
                self.value = Int(session.outputVolume * 100)
            }
        }
    }
}
