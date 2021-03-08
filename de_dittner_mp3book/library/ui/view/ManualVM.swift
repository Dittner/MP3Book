//
//  ManualVM.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Combine
import Foundation

class ManualVM: ViewModel, ObservableObject {
    static var shared: ManualVM = ManualVM(id: .manual)
    @Published var isMacOSSelected: Bool = true

    override init(id: ScreenID) {
        logInfo(msg: "ManualVM init")
        super.init(id: id)
    }

    func goBack() {
        navigator.goBack(to: .library)
    }

    func removeManual() {
        UserDefaults.standard.set(true, forKey: "isManualHidden")
        goBack()
    }
}
