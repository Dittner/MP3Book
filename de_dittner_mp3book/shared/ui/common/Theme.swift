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
}

struct LightTheme: Theme {
    let id: String = "light"
    let transparent: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let tint: UIColor = UIColor(rgb: 0x5A595C)
    let toolbarColors = [Color(rgb: 0xf7f7f6), Color(rgb: 0xf2f2f1)]
    let playerColors = [Color(rgb: 0xefeeed), Color(rgb: 0xf4f1f1)]
    let appBgColors = [Color(rgb: 0xf7f7f6), Color(rgb: 0xf7f7f6), Color(rgb: 0xf4f1f1)]
    let text: UIColor = UIColor(rgb: 0x5A595C)
    let selectedText: UIColor = UIColor(rgb: 0x5A595C)
    let play: UIColor = UIColor(rgb: 0xAB466A)
    let separator: UIColor = UIColor(rgb: 0, alpha: 0.1)
    let sliderTrack: UIColor = UIColor(rgb: 0, alpha: 0.2)
    let listCellBg: UIColor = UIColor(rgb: 0xFFFFFF, alpha: 0.5)
    let tabBarSelectedBg: UIColor = UIColor(rgb: 0xe4e4e3)
    let tabBarSelectedText: UIColor = UIColor(rgb: 0xAB466A)
    let popupBg: UIColor = UIColor(rgb: 0xf7f7f6)
    let inputBg: UIColor = UIColor(rgb: 0xFFFFFF, alpha: 0.5)
    let inputText: UIColor = UIColor(rgb: 0x5A595C)
    let deleteBtnBg: UIColor = UIColor(rgb: 0xEAD6DC)
    let deleteBtnIcon: UIColor = UIColor(rgb: 0x5A595C)
}

struct DarkTheme: Theme {
    let id: String = "dark"
    let transparent: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let tint: UIColor = UIColor(rgb: 0xB2B1A8)
    let toolbarColors = [Color(rgb: 0x101011), Color(rgb: 0x1C1C1D)]
    let playerColors = [Color(rgb: 0x1B1819), Color(rgb: 0x161213)]
    let appBgColors = [Color(rgb: 0x101011), Color(rgb: 0x131414), Color(rgb: 0x161213)]
    let text: UIColor = UIColor(rgb: 0x5A595C)
    let selectedText: UIColor = UIColor(rgb: 0xEBEAE3)
    let play: UIColor = UIColor(rgb: 0xEBD6BA)
    let separator: UIColor = UIColor(rgb: 0xFFFFFF, alpha: 0.1)
    let sliderTrack: UIColor = UIColor(rgb: 0xFFFFFF, alpha: 0.2)
    let listCellBg: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let tabBarSelectedBg: UIColor = UIColor(rgb: 0x131414)
    let tabBarSelectedText: UIColor = UIColor(rgb: 0xEBEAE3)
    let popupBg: UIColor = UIColor(rgb: 0x323035)
    let inputBg: UIColor = UIColor(rgb: 0, alpha: 0.5)
    let inputText: UIColor = UIColor(rgb: 0xB2B1A8)
    let deleteBtnBg: UIColor = UIColor(rgb: 0x4F1D35)
    let deleteBtnIcon: UIColor = UIColor(rgb: 0xB2B1A8)
}

class ThemeObservable: ObservableObject {
    @Published var theme: Theme

    static var shared: ThemeObservable = ThemeObservable()

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
