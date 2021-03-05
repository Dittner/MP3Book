//
//  URLExtension.swift
//  MP3Book
//
//  Created by Dittner on 25/05/2019.
//

import Foundation

extension Array where Element: Hashable {
    func removeDuplicates() -> [Element] {
        return Array(Set(self))
    }
}

extension Array where Element: Identifiable {
    func getFirstIndexOf(item: Element) -> Int? {
        for (index, e) in enumerated() where e.id == item.id {
            return index
        }
        return nil
    }
}
