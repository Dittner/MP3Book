//
//  Constants.swift
//  MP3Book
//
//  Created by Alexander Dittner on 27.02.2021.
//

import SwiftUI

class Constants {
    static let font: FontConstants = FontConstants()
    static let size: SizeConstants = SizeConstants()
}

class FontConstants {
    let b16: Font
    let b14: Font
    let r16: Font
    let r15: Font
    let r14: Font
    let r12: Font
    let r11: Font
    let l13: Font
    let t26: Font
    let t16: Font

    init() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            b16 = Font.custom(.helveticaNeueBold, size: 16)
            b14 = Font.custom(.helveticaNeueBold, size: 14)
            r16 = Font.custom(.helveticaNeue, size: 16)
            r15 = Font.custom(.helveticaNeue, size: 15)
            r14 = Font.custom(.helveticaNeue, size: 14)
            r12 = Font.custom(.helveticaNeue, size: 12)
            r11 = Font.custom(.helveticaNeue, size: 11)
            l13 = Font.custom(.helveticaLight, size: 13)
            t26 = Font.custom(.helveticaThin, size: 26)
            t16 = Font.custom(.helveticaThin, size: 16)
        } else {
            b16 = Font.custom(.helveticaNeueBold, size: 17)
            b14 = Font.custom(.helveticaNeueBold, size: 15)
            r16 = Font.custom(.helveticaNeue, size: 17)
            r15 = Font.custom(.helveticaNeue, size: 16)
            r14 = Font.custom(.helveticaNeue, size: 15)
            r12 = Font.custom(.helveticaNeue, size: 13)
            r11 = Font.custom(.helveticaNeue, size: 12)
            l13 = Font.custom(.helveticaLight, size: 14)
            t26 = Font.custom(.helveticaThin, size: 28)
            t16 = Font.custom(.helveticaThin, size: 17)
        }
    }
}

class SizeConstants {
    let popupWidth: CGFloat
    let bookListCellHeight: CGFloat
    let fileListCellHeight: CGFloat
    let folderListCellHeight: CGFloat
    let playerHeight: CGFloat
    let playRateSelectorWidth: CGFloat
    let navigationBarHeight: CGFloat

    init() {
        if UIDevice.current.userInterfaceIdiom == .phone {
            popupWidth = 300
            bookListCellHeight = 70
            folderListCellHeight = 70
            fileListCellHeight = 60
            playerHeight = 180
            playRateSelectorWidth = 100
            navigationBarHeight = 60
        } else {
            popupWidth = 450
            bookListCellHeight = 80
            folderListCellHeight = 80
            fileListCellHeight = 70
            playerHeight = 200
            playRateSelectorWidth = 120
            navigationBarHeight = 60
        }
    }
}
