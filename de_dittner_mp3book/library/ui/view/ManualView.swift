//
//  ManualView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 07.03.2021.
//

import SwiftUI

struct ManualView: View {
    @ObservedObject var vm = ManualVM.shared
    @ObservedObject var themeObservable = ThemeObservable.shared

    var body: some View {
        VStack(alignment: .center, spacing: -20) {
            NavigationBar {
                HStack {
                    IconButton(iconName: "back", iconColor: themeObservable.theme.tint.color) {
                        self.vm.goBack()
                    }

                    Spacer()
                }
            }

            OSTabBar()
                .navigationBarShadow()

            ManualContent()
                .edgesIgnoringSafeArea(.bottom)
        }.frame(maxWidth: .infinity)
    }
}

struct ManualContent: View {
    @ObservedObject var vm = ManualVM.shared
    @ObservedObject var themeObservable = ThemeObservable.shared

    var body: some View {
        ScrollView {
            Spacer().frame(height: 40)
            VStack(alignment: .leading, spacing: 20) {
                if vm.isMacOSSelected {
                    Text("ManualMac")
                        .baselineOffset(5.0)
                        .multilineTextAlignment(.leading)

                    Image("ManualMac")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 1.5 * 786 / UIScreen.main.scale)
                        .allowsTightening(false)
                } else {
                    Text("ManualWin1-2")
                        .baselineOffset(5.0)
                        .multilineTextAlignment(.leading)

                    Image("ManualWinSelectDevice")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 612 / UIScreen.main.scale)
                        .allowsTightening(false)

                    Text("ManualWin3")
                        .baselineOffset(5.0)
                        .multilineTextAlignment(.leading)

                    Image("ManualWinSharedFiles")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 617 / UIScreen.main.scale)
                        .allowsTightening(false)

                    Text("ManualWin4-5")
                        .baselineOffset(5.0)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .font(Constants.font.r16)
            .foregroundColor(themeObservable.theme.text.color)
            .padding(.horizontal, Constants.size.actionBtnSize / 2)
            Spacer().frame(height: 40)
        }
        .clipped()
    }
}

struct OSTabBar: View {
    @ObservedObject private var themeObservable = ThemeObservable.shared
    @ObservedObject var vm = ManualVM.shared

    init() {
        print("OSTabBar init")
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TabBarButton(icon: "winLogo", title: "Windows", theme: themeObservable.theme, selected: !vm.isMacOSSelected) {
                if self.vm.isMacOSSelected {
                    self.vm.isMacOSSelected = false
                }
            }

            TabBarButton(icon: "appleLogo", title: "MacOS", theme: themeObservable.theme, selected: vm.isMacOSSelected) {
                if !self.vm.isMacOSSelected {
                    vm.isMacOSSelected = true
                }
            }
        }
        .zIndex(1)
        .frame(height: Constants.size.playModeTabBarHeight)
        .cornerRadius(radius: 20, corners: [.bottomLeft, .bottomRight])
        .padding(.bottom, 0)
    }
}
