//
//  SeparatorView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 11.02.2021.
//

import Combine
import SwiftUI

struct VSeparatorView: View {
    let verticalPadding: CGFloat
    let color: Color

    init(color: Color, verticalPadding: CGFloat = 0) {
        self.color = color
        self.verticalPadding = verticalPadding
    }

    var body: some View {
        color
            .padding(.vertical, verticalPadding)
            .frame(width: 0.5)
            .frame(maxHeight: .infinity)
    }
}
