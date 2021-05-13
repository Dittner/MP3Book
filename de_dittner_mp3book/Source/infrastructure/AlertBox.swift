//
//  AlertBox.swift
//  MP3Book
//
//  Created by Alexander Dittner on 24.02.2021.
//

import Combine
import SwiftUI

class AlertBox: ObservableObject {
    @Published var message: AlertMessage?

    func show(title: LocalizedStringKey, details: LocalizedStringKey) {
        if message == nil {
            message = AlertMessage(title: title, details: details)
        }
    }
}

struct AlertMessage: Identifiable {
    let id = UID()
    let title: LocalizedStringKey
    let details: LocalizedStringKey
}
