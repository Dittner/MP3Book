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
    var appBgColors: [Color] { get }
    var text: UIColor { get }
    var selectedText: UIColor { get }
    var play: UIColor { get }
    var separator: UIColor { get }
    var sliderTrack: UIColor { get }
    var listCellBg: UIColor { get }
    var popupBg: UIColor { get }
}

struct LightTheme: Theme {
    let id: String = "light"
    let transparent: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let tint: UIColor = UIColor(rgb: 0x5A595C)
    let toolbarColors = [Color.black.opacity(0), Color.black.opacity(0.05)]
    let appBgColors = [Color(rgb: 0xebeae3), Color(rgb: 0xebeae3), Color(rgb: 0xe3d2cf)]
    let text: UIColor = UIColor(rgb: 0x5A595C)
    let selectedText: UIColor = UIColor(rgb: 0x5A595C)
    let play: UIColor = UIColor(rgb: 0xAB466A)
    let separator: UIColor = UIColor(rgb: 0, alpha: 0.1)
    let sliderTrack: UIColor = UIColor(rgb: 0, alpha: 0.2)
    let listCellBg: UIColor = UIColor(rgb: 0xffFFff, alpha: 0.5)
    let popupBg: UIColor = UIColor(rgb: 0xEBEAE3)
}

struct DarkTheme: Theme {
    let id: String = "dark"
    let transparent: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let tint: UIColor = UIColor(rgb: 0xB2B1A8)
    let toolbarColors = [Color.white.opacity(0), Color.white.opacity(0.05)]
    let appBgColors = [Color(rgb: 0x101011), Color(rgb: 0x131414), Color(rgb: 0x181213)]
    let text: UIColor = UIColor(rgb: 0x5A595C)
    let selectedText: UIColor = UIColor(rgb: 0xEBEAE3)
    let play: UIColor = UIColor(rgb: 0xFFDBA8)
    let separator: UIColor = UIColor(rgb: 0xffFFff, alpha: 0.1)
    let sliderTrack: UIColor = UIColor(rgb: 0xffFFff, alpha: 0.2)
    let listCellBg: UIColor = UIColor(rgb: 0, alpha: 0.001)
    let popupBg: UIColor = UIColor(rgb: 0x323035)
}

class ThemeObservable: ObservableObject {
    @Published var theme: Theme
    
    static var shared:ThemeObservable = ThemeObservable()

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
