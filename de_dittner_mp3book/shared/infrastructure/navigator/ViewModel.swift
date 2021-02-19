//
//  ViewModel.swift
//  MP3Book
//
//  Created by Alexander Dittner on 19.02.2021.
//

import Combine

class ViewModel {
    private(set) var screenID: ScreenID
    private(set) var navigator: Navigator
    private var navigatorSubscription: AnyCancellable?

    init(id: ScreenID) {
        screenID = id
        navigator = Navigator.shared

        navigatorSubscription = navigator.$screenPosition
            .sink { position in
                if position.leading == self.screenID || position.trailing == self.screenID {
                    self.screenDeactivated()
                } else if position.center == self.screenID {
                    self.screenActivated()
                }
            }
    }

    func screenActivated() {
        logInfo(msg: "\(screenID.rawValue) screen has been activated")
    }

    func screenDeactivated() {
        logInfo(msg: "\(screenID.rawValue) screen has been deactivated")
    }
}
