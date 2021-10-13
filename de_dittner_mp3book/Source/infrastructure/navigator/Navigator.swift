//
//  Navigator.swift
//  MP3Book
//
//  Created by Alexander Dittner on 19.02.2021.
//

import Combine
import SwiftUI

enum ScreenID: String {
    case bookList
    case audioFileList
    case library
    case manual
}

struct ScreenPosition {
    let leading: ScreenID?
    let center: ScreenID
    let trailing: ScreenID?
    let goBack: Bool

    func xPosition(id: ScreenID) -> CGFloat? {
        if let leadingScreenID = leading, leadingScreenID == id {
            return -1
        } else if center == id {
            return 0
        } else if let trailingScreenID = trailing, trailingScreenID == id {
            return 1
        } else {
            return nil
        }
    }
}

struct Screen {
    let activated: ScreenID
    let deactivated: ScreenID?
}

class Navigator: ObservableObject {
    @Published var screenPosition: ScreenPosition
    @Published var screen: Screen

    init() {
        screen = Screen(activated: .bookList, deactivated: nil)
        screenPosition = ScreenPosition(leading: nil, center: .bookList, trailing: nil, goBack: false)
    }

    func goBack(to: ScreenID) {
        screen = Screen(activated: to, deactivated: screen.activated)
        withAnimation {
            screenPosition = ScreenPosition(leading: nil, center: to, trailing: screenPosition.center, goBack: true)
        }
    }

    func navigate(to: ScreenID) {
        screen = Screen(activated: to, deactivated: screen.activated)
        withAnimation {
            screenPosition = ScreenPosition(leading: screenPosition.center, center: to, trailing: nil, goBack: false)
        }
    }
}
