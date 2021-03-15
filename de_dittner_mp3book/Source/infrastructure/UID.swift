//
//  UID.swift
//  MP3Book
//
//  Created by Alexander Dittner on 12.02.2021.
//

import Foundation
typealias UID = Int64

extension UID {
    private static var ids: UID = UID(Date().timeIntervalSince1970)

    init() {
        UID.ids += 1
        self = UID.ids
    }
}
