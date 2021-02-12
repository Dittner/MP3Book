//
//  SeparatorView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Combine
import SwiftUI

struct SeparatorView: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    var body: some View {
        
        themeObservable.theme.separator.color
            .padding(.horizontal, -50)
            .frame(height: 0.5)
            .frame(maxWidth: .infinity)
    }
}
