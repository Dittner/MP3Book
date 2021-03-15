//
//  DownArrow.swift
//  MP3Book
//
//  Created by Alexander Dittner on 18.02.2021.
//

import SwiftUI

struct DownArrow: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let w = rect.width
            let h = rect.height

            path.addLines([
                CGPoint(x: 0, y: 0),
                CGPoint(x: w, y: 0),
                CGPoint(x: w / 2, y: h),
                CGPoint(x: 0, y: 0)])

            path.closeSubpath()
        }
    }
}
