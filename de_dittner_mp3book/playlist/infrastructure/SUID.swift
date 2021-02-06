//
//  SessionUID.swift
//  MP3Book
//
//  Created by Dittner on 07/06/2019.
//
//persists across application launches
typealias SUID = UInt64

extension SUID {
    private static var ids:SUID = 0

    init() {
        SUID.ids += 1
        self = SUID.ids
    }
}

protocol SUIDentifiable: AnyObject {
    var suid: SUID { get }
}
