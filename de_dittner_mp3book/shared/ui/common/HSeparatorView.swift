//
//  SeparatorView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Combine
import SwiftUI

struct HSeparatorView: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    
    let horizontalPadding:CGFloat
    
    init(horizontalPadding:CGFloat = 0) {
        self.horizontalPadding = horizontalPadding
    }
    var body: some View {
        
        themeObservable.theme.separator.color
            .padding(.horizontal, horizontalPadding)
            .frame(height: 0.5)
            .frame(maxWidth: .infinity)
    }
}
