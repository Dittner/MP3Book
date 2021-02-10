//
//  Buttons.swift
//  MP3Book
//
//  Created by Alexander Dittner on 08.02.2021.
//

import SwiftUI

struct IconButtonStyle: ButtonStyle {
    var iconName: String
    var theme: Theme
    var width: CGFloat = 50
    var height: CGFloat = 50

    func makeBody(configuration: Self.Configuration) -> some View {
        Image(iconName)
            .renderingMode(.template)
            .foregroundColor(configuration.isPressed ? theme.tint.color : theme.tint.color.opacity(0.5))
            .frame(width: width, height: height)
    }
}

struct IconButton: View {
    var iconName: String
    var iconColor: Color
    let onAction: () -> Void

    @State private var onPressed = false

    var body: some View {
        Image(iconName)
            .renderingMode(.template)
            //.frame(width: 50, height: 50)
            .contentShape(Rectangle())
            .foregroundColor(onPressed ? iconColor.opacity(0.5) : iconColor)
            .onTapGesture {
                self.onAction()
            }
            .pressAction {
                self.onPressed = true
            } onRelease: {
                self.onPressed = false
            }
    }
}

struct TextButton: View {
    var text: String
    var textColor: Color
    var font: Font
    let onAction: () -> Void

    @State private var onPressed = false

    var body: some View {
        Text(text)
            .lineLimit(1)
            .font(font)
            .foregroundColor(onPressed ? textColor.opacity(0.5) : textColor)
            .onTapGesture {
                self.onAction()
            }
            .pressAction {
                self.onPressed = true
            } onRelease: {
                self.onPressed = false
            }
    }
}

struct PressActions: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void

    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged({ _ in
                        onPress()
                    })
                    .onEnded({ _ in
                        onRelease()
                    })
            )
    }
}

extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}
