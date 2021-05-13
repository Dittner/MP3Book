//
//  ManualVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class ManualVM: ViewModel, ObservableObject {
    @Published var isMacOSSelected: Bool = true

    init(context: MP3BookContextProtocol) {
        logInfo(msg: "ManualVM init")
        super.init(id: .manual, navigator: context.ui.navigator)
    }

    func goBack() {
        navigator.goBack(to: .library)
    }

    func removeManual() {
        UserDefaults.standard.set(true, forKey: Constants.keys.isManualHidden)
        goBack()
    }
}
