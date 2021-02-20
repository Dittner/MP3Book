//
//  Font++.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

//
//    Text("Title")
//        .font(Font.custom(.helveticaNeue, size: 17))
//        .minimumScaleFactor(12 / 17)
//        .lineLimit(1)

import SwiftUI

enum FontName: String {
    case helveticaNeue = "Helvetica Neue"
    case helveticaThin = "Helvetica Neue Thin"
    case helveticaNeueBold = "Helvetica Neue Bold"
}

extension UIFont {
    convenience init(name: FontName, size: CGFloat) {
        self.init(name: name.rawValue, size: size)!
    }
}

extension Font {
    public static let m3b = (navigationTitle: Font.custom(.helveticaNeueBold, size: 17),
                             cancelButton: Font.custom(.helveticaNeue, size: 15),
                             applyButton: Font.custom(.helveticaNeueBold, size: 15),
                             backButton: Font.custom(.helveticaNeue, size: 15))

    static func custom(_ name: FontName, size: CGFloat) -> Font {
        Font.custom(name.rawValue, size: size)
    }

    static func printAllSystemFonts() {
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print("Family: \(family) Font names: \(names)")
        }
    }
}
