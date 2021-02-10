//
//  Separator.swift
//  MP3Book
//
//  Created by Alexander Dittner on 10.02.2021.
//

import SwiftUI

struct Separator: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        return path
    }
}
