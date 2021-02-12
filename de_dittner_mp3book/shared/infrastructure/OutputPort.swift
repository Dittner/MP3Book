//
//  OutputPort.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Combine
import SwiftUI

class OutputPort<Element>:ObservableObject {
    var value = CurrentValueSubject<[Element], Never>([])
    
    func write(_ elements: [Element]) {
        value.send(elements)
    }
}
