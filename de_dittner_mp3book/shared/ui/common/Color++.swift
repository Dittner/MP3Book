//
//  Color++.swift
//  MP3Book
//
//  Created by Alexander Dittner on 07.02.2021.
//

import SwiftUI

extension Color {
    init(rgb: UInt) {
        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}

extension UIColor {
    convenience init(rgb: UInt, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }

    var color: Color {
        Color(self)
    }
}
