//
//  DispatchQueue.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Foundation
import Foundation

typealias Thread = DispatchQueue

extension Thread {

    static func background(_ task: @escaping () -> ()) {
        Thread.global(qos: .background).async {
            task()
        }
    }

    static func main(_ task: @escaping () -> ()) {
        Thread.main.async {
            task()
        }
    }
}
