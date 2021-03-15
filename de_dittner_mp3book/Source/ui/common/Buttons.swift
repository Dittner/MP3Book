//
//  Buttons.swift
//  MP3Book
//
//  Created by Alexander Dittner on 08.02.2021.
//

import SwiftUI

struct IconButton: View {
    var name: FontIcon
    var size: CGFloat
    var color: Color
    var width: CGFloat = Constants.size.actionBtnSize
    var height: CGFloat = 50
    let onAction: () -> Void

    @State private var onPressed = false

    var body: some View {
        Text(name.rawValue)
            .lineLimit(1)
            .font(.custom("mp3bookIcons", size: size * Constants.scaleFactor))
            .frame(width: width, height: height)
            .contentShape(Rectangle())
            .foregroundColor(onPressed ? color.opacity(0.5) : color)
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
    var text: LocalizedStringKey
    var textColor: Color
    var font: Font
    var height: CGFloat = 50
    let onAction: () -> Void

    @State private var onPressed = false

    var body: some View {
        Text(text)
            .lineLimit(1)
            .font(font)
            .foregroundColor(onPressed ? textColor.opacity(0.5) : textColor)
            .frame(height: height)
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

struct TextButton2: View {
    var text: String
    var textColor: Color
    var font: Font
    var height: CGFloat = 50
    let onAction: () -> Void

    @State private var onPressed = false

    var body: some View {
        Text(text)
            .lineLimit(1)
            .font(font)
            .foregroundColor(onPressed ? textColor.opacity(0.5) : textColor)
            .frame(height: height)
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

struct TabBarButton: View {
    var icon: FontIcon
    var iconSize: CGFloat
    var title: LocalizedStringKey
    var theme: Theme
    let selected: Bool
    let onAction: () -> Void

    @State private var onPressed = false

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Spacer()

            Icon(name: icon, size: iconSize)
                .allowsHitTesting(false)

            Text(title)
                .font(Constants.font.r11)
                .lineLimit(1)
        }
        .padding(5)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(onPressed || selected ? theme.tabBarSelectedBg.color : theme.toolbarColors[1])
        .foregroundColor(onPressed || selected ? theme.tabBarSelectedText.color : theme.text.color)
        .zIndex(10)
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

extension View {
    func pressAction(onPress: @escaping (() -> Void), onRelease: @escaping (() -> Void)) -> some View {
        modifier(PressActions(onPress: {
            onPress()
        }, onRelease: {
            onRelease()
        }))
    }
}
