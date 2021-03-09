//
//  Constants.swift
//  MP3Book
//
//  Created by Alexander Dittner on 27.02.2021.
//

import SwiftUI

class Constants {
    static let scaleFactor: CGFloat = getScaleFactor()
    static let font = FontConstants(getScaleFactor())
    static let size = SizeConstants(getScaleFactor())

    private static func getScaleFactor() -> CGFloat {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return 1
        } else if UIDevice.current.maxSizeInPx < 2100 {
            return 9 / 8
        } else {
            return 4 / 3
        }
    }
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

    init(_ scaleFactor: CGFloat) {
        b16 = Font.custom(.helveticaNeueBold, size: 16 * scaleFactor)
        b14 = Font.custom(.helveticaNeueBold, size: 14 * scaleFactor)
        r16 = Font.custom(.helveticaNeue, size: 16 * scaleFactor)
        r15 = Font.custom(.helveticaNeue, size: 15 * scaleFactor)
        r14 = Font.custom(.helveticaNeue, size: 14 * scaleFactor)
        r12 = Font.custom(.helveticaNeue, size: 12 * scaleFactor)
        r11 = Font.custom(.helveticaNeue, size: 11 * scaleFactor)
        l13 = Font.custom(.helveticaLight, size: 13 * scaleFactor)
        t26 = Font.custom(.helveticaThin, size: 26 * scaleFactor)
        t16 = Font.custom(.helveticaThin, size: 16 * scaleFactor)
    }
}

enum FontIcon: String {
    case add = "\u{e900}"
    case addBookmark = "\u{e901}"
    case appleLogo = "\u{e902}"
    case audioFile = "\u{e903}"
    case back = "\u{e904}"
    case bookmark = "\u{e905}"
    case bookmarkSmall = "\u{e906}"
    case checkBox = "\u{e907}"
    case checkBoxSelected = "\u{e908}"
    case damaged = "\u{e909}"
    case delete = "\u{e90a}"
    case folder = "\u{e90b}"
    case next = "\u{e90c}"
    case open = "\u{e90d}"
    case pause = "\u{e90e}"
    case play = "\u{e90f}"
    case playerBackward = "\u{e910}"
    case playerForward = "\u{e911}"
    case playerPause = "\u{e912}"
    case playerPlay = "\u{e913}"
    case sort = "\u{e914}"
    case volume = "\u{e915}"
    case winLogo = "\u{e916}"
}

class SizeConstants {
    let popupWidth: CGFloat
    let bookListCellHeight: CGFloat
    let fileListCellHeight: CGFloat
    let folderListCellHeight: CGFloat
    let playerHeight: CGFloat
    let playRateSelectorWidth: CGFloat
    let navigationBarHeight: CGFloat
    let playModeTabBarHeight: CGFloat
    let playerSliderHeight: CGFloat
    let actionBtnSize: CGFloat

    init(_ scaleFactor: CGFloat) {
        popupWidth = 300 * scaleFactor
        bookListCellHeight = 75 * scaleFactor
        folderListCellHeight = 75 * scaleFactor
        fileListCellHeight = 60 * scaleFactor
        playerHeight = 180 * scaleFactor
        playRateSelectorWidth = 100 * scaleFactor
        navigationBarHeight = 60 * scaleFactor
        playModeTabBarHeight = 65 * scaleFactor
        playerSliderHeight = 24 * scaleFactor
        actionBtnSize = 50 * scaleFactor
    }
}
