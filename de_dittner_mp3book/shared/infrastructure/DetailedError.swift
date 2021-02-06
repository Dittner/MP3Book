//
//  DetailedError.swift
//  MP3Book
//
//  Created by Alexander Dittner on 04.02.2021.
//

import Foundation
protocol DetailedError: LocalizedError {
}

extension DetailedError {
    var errorDescription: String? { return "Error: \(self)" }
}
