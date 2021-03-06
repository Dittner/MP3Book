//
//  ManualView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 07.03.2021.
//

import SwiftUI

struct ManualView: View {
    @ObservedObject var vm: ManualVM
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        VStack(alignment: .center, spacing: -20) {
            NavigationBar { navigationBarSideWidth in
                IconButton(name: .back, size: 18, color: themeManager.theme.navigation.color) {
                    self.vm.goBack()
                }
                .navigationBarLeading(navigationBarSideWidth)

                Text("ManualTitle")
                    .font(Constants.font.b16)
                    .foregroundColor(themeManager.theme.tint.color)
                    .navigationBarTitle(navigationBarSideWidth)

                IconButton(name: .delete, size: 18, color: themeManager.theme.navigation.color) {
                    self.vm.removeManual()
                }
                .navigationBarTrailing(navigationBarSideWidth)
            }

            OSTabBar(vm: vm)
                .navigationBarShadow()

            ManualContent(vm: vm)
                .edgesIgnoringSafeArea(.bottom)
        }.frame(maxWidth: .infinity)
    }
}

struct ManualContent: View {
    @ObservedObject var vm: ManualVM
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        ScrollView {
            Spacer().frame(height: 40)
            VStack(alignment: .leading, spacing: 20) {
                if vm.isMacOSSelected {
                    Text("ManualMac")
                        .baselineOffset(5.0)
                        .multilineTextAlignment(.leading)
                        .layoutPriority(1)

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
            }
            .font(Constants.font.r16)
            .foregroundColor(themeManager.theme.text.color)
            .padding(.horizontal, Constants.size.actionBtnSize / 2)
            Spacer().frame(height: 40)
        }
        .clipped()
    }
}

struct OSTabBar: View {
    @ObservedObject var vm: ManualVM
    @EnvironmentObject var themeManager: ThemeManager

    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            TabBarButton(icon: .winLogo, iconSize: 15, title: "Windows", theme: themeManager.theme, selected: !vm.isMacOSSelected) {
                if self.vm.isMacOSSelected {
                    self.vm.isMacOSSelected = false
                }
            }

            TabBarButton(icon: .appleLogo, iconSize: 15, title: "MacOS", theme: themeManager.theme, selected: vm.isMacOSSelected) {
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
