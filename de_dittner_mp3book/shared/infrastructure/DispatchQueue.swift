//
//  DispatchQueue.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import Foundation
import Foundation

typealias Async = DispatchQueue

extension Async {

    static func background(_ task: @escaping () -> ()) {
        Async.global(qos: .background).async {
            task()
        }
    }

    static func main(_ task: @escaping () -> ()) {
        Async.main.async {
            task()
        }
    }
}
