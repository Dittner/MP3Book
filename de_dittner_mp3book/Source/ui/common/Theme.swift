//
//  Theme.swift
//  MP3Book
//
//  Created by Alexander Dittner on 08.02.2021.
//

import Foundation
import SwiftUI
import UIKit

protocol Theme {
    var id: String { get }
    var transparent: UIColor { get }
    var tint: UIColor { get }
    var toolbarColors: [Color] { get }
    var playerColors: [Color] { get }
    var appBgColors: [Color] { get }
    var text: UIColor { get }
    var selectedText: UIColor { get }
    var play: UIColor { get }
    var separator: UIColor { get }
    var sliderTrack: UIColor { get }
    var listCellBg: UIColor { get }
    var tabBarSelectedBg: UIColor { get }
    var tabBarSelectedText: UIColor { get }
    var popupBg: UIColor { get }
    var inputBg: UIColor { get }
    var inputText: UIColor { get }
    var deleteBtnBg: UIColor { get }
    var deleteBtnIcon: UIColor { get }
    var navigation: UIColor { get }
}

struct LightTheme: Theme {
    let id: String = "light"
    let tint: UIColor = UIColor(rgb: 0x5A595C)
    let text: UIColor = UIColor(rgb: 0x5A595C)
    let selectedText: UIColor = UIColor(rgb: 0x5A595C)
    let inputText: UIColor = UIColor(rgb: 0x5A595C)
    let deleteBtnIcon: UIColor = UIColor(rgb: 0x5A595C)

    let listCellBg: UIColor = UIColor(rgb: 0xFFFFFF, alpha: 0.5)
    let inputBg: UIColor = UIColor(rgb: 0xFFFFFF, alpha: 0.75)

    let toolbarColors = [Color(rgb: 0xF7F7F6), Color(rgb: 0xF2F2F1)]
    let appBgColors = [Color(rgb: 0xF7F7F6), Color(rgb: 0xF7F7F6), Color(rgb: 0xF4F1F1)]

    let playerColors = [Color(rgb: 0xEFEEED), Color(rgb: 0xF4F1F1)]

    let play: UIColor = UIColor(rgb: 0xAB466A)
    let tabBarSelectedText: UIColor = UIColor(rgb: 0xAB466A)

    let transparent: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let separator: UIColor = UIColor(rgb: 0, alpha: 0.1)
    let sliderTrack: UIColor = UIColor(rgb: 0, alpha: 0.2)

    let tabBarSelectedBg: UIColor = UIColor(rgb: 0xE4E4E3)
    let popupBg: UIColor = UIColor(rgb: 0xEFEFEE)
    let deleteBtnBg: UIColor = UIColor(rgb: 0xEAD6DC)
    let navigation: UIColor = UIColor(rgb: 0x8D8089)
}

struct DarkTheme: Theme {
    let id: String = "dark"
    let tint: UIColor = UIColor(rgb: 0xA0A0A0)
    let inputText: UIColor = UIColor(rgb: 0xA0A0A0)
    let deleteBtnIcon: UIColor = UIColor(rgb: 0xA0A0A0)
    let navigation: UIColor = UIColor(rgb: 0xA0A0A0)

    let tabBarSelectedText: UIColor = UIColor(rgb: 0xA0A0A0)

    let toolbarColors = [Color(rgb: 0x101011), Color(rgb: 0x1C1C1D)]
    let playerColors = [Color(rgb: 0x1B1819), Color(rgb: 0x161213)]
    let appBgColors = [Color(rgb: 0x101011), Color(rgb: 0x131414), Color(rgb: 0x161213)]

    let text: UIColor = UIColor(rgb: 0x5A595C)
    let selectedText: UIColor = UIColor(rgb: 0xEBEAE3)
    let play: UIColor = UIColor(rgb: 0xEBD6BA)

    let separator: UIColor = UIColor(rgb: 0xFFFFFF, alpha: 0.1)
    let sliderTrack: UIColor = UIColor(rgb: 0xFFFFFF, alpha: 0.2)

    let transparent: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let listCellBg: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let inputBg: UIColor = UIColor(rgb: 0, alpha: 0.75)

    let tabBarSelectedBg: UIColor = UIColor(rgb: 0x131414)

    let popupBg: UIColor = UIColor(rgb: 0x323035)
    let deleteBtnBg: UIColor = UIColor(rgb: 0x4F1D35)
}

class ThemeManager: ObservableObject {
    @Published var theme: Theme

    private let light: Theme
    private let dark: Theme
    init() {
        light = LightTheme()
        dark = DarkTheme()
        theme = light
    }

    func selectDarkTheme() {
        if theme.id != dark.id {
            theme = dark
            logInfo(msg: "Selected theme: \(theme.id)")
        }
    }

    func selectLightTheme() {
        if theme.id != light.id {
            theme = light
            logInfo(msg: "Selected theme: \(theme.id)")
        }
    }
}
