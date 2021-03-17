//
//  ContentView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 01.02.2021.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    @ObservedObject var vm = LibraryVM.shared

    var body: some View {
        VStack(alignment: .center, spacing: -20) {
            NavigationBar { navigationBarSideWidth in
                TextButton(text: "Cancel", textColor: themeObservable.theme.navigation.color, font: Constants.font.r14) {
                    vm.cancel()
                }
                .accessibilityIdentifier("cancel")
                .padding(.horizontal)
                .navigationBarLeading(navigationBarSideWidth)

                Text("Library")
                    .font(Constants.font.b16)
                    .foregroundColor(themeObservable.theme.tint.color)
                    .navigationBarTitle(navigationBarSideWidth)

                TextButton(text: "Done", textColor: themeObservable.theme.navigation.color, font: Constants.font.b14) {
                    vm.apply()
                }
                .padding(.horizontal)
                .navigationBarTrailing(navigationBarSideWidth)
            }.navigationBarShadow()

            LibraryContent()
                .frame(maxWidth: .infinity)
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct LibraryContent: View {
    @ObservedObject var vm = LibraryVM.shared
    @ObservedObject var themeObservable = ThemeObservable.shared

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if vm.isLoading {
                Spacer()
                ActivityIndicator(isAnimating: $vm.isLoading)
                Spacer()
            } else {
                ScrollView {
                    Spacer().frame(height: 20)
                    LazyVStack(alignment: .center, spacing: 0) {
                        if vm.wrappedFolders.count > 0 {
                            Text("App Data")
                                .font(Constants.font.r11)
                                .lineLimit(1)
                                .foregroundColor(themeObservable.theme.text.color)
                                .frame(height: 20, alignment: .center)

                            HSeparatorView(horizontalPadding: 0)

                            ForEach(vm.wrappedFolders) { wrappedFolder in
                                WrapperFolderCell(w: wrappedFolder)
                            }

                            if vm.wrappedPlaylists.count > 0 {
                                Text("Media Library")
                                    .font(Constants.font.r11)
                                    .lineLimit(1)
                                    .foregroundColor(themeObservable.theme.text.color)
                                    .frame(height: 20, alignment: .center)

                                HSeparatorView(horizontalPadding: 0)

                                ForEach(vm.wrappedPlaylists) { wrappedPlaylist in
                                    WrapperPlaylistCell(w: wrappedPlaylist)
                                }
                            }
                        }

                        Spacer()

                    }.frame(maxHeight: .infinity)
                }
                .clipped()

                if !vm.isManualHidden {
                    TextButton(text: "howToAddFiles", textColor: themeObservable.theme.navigation.color, font: Constants.font.b14, height: 100) {
                        vm.openManual()
                    }.frame(maxWidth: .infinity)
                        .background(Rectangle()
                            .fill(LinearGradient(gradient: Gradient(colors: themeObservable.theme.playerColors), startPoint: .top, endPoint: .bottom))
                            .cornerRadius(radius: 20, corners: [.topLeft, .topRight]))
                }
            }
        }
    }
}

struct WrapperFolderCell: View {
    @ObservedObject var wrappedFolder: Wrapper<Folder>
    let title: String
    let subTitle: String
    let isSubFolder: Bool

    init(w: Wrapper<Folder>) {
        wrappedFolder = w
        title = w.data.title
        isSubFolder = w.data.depth > 1
        subTitle = "\(w.data.files.count), \(DateTimeUtils.secToHHMMSS(w.data.totalDuration))"
    }

    var body: some View {
        ListCell(title: title, subTitle: subTitle, isSubFolder: isSubFolder, selected: $wrappedFolder.selected)
    }
}

struct WrapperPlaylistCell: View {
    @ObservedObject var wrappedFolder: Wrapper<Playlist>
    let title: String
    let subTitle: String

    init(w: Wrapper<Playlist>) {
        wrappedFolder = w
        title = w.data.title
        subTitle = "\(w.data.files.count), \(DateTimeUtils.secToHHMMSS(w.data.totalDuration))"
    }

    var body: some View {
        ListCell(title: title, subTitle: subTitle, isSubFolder: false, selected: $wrappedFolder.selected)
    }
}

struct ListCell: View {
    @ObservedObject var themeObservable = ThemeObservable.shared

    let title: String
    let subTitle: String
    let isSubFolder: Bool
    @Binding var selected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Icon(name: .folder, size: 12)
                .allowsHitTesting(false)
                .frame(width: isSubFolder ? 1.5 * Constants.size.actionBtnSize : Constants.size.actionBtnSize)

            VStack(alignment: .center, spacing: 4) {
                Spacer()

                Text(title)
                    .font(Constants.font.r15)
                    .minimumScaleFactor(12 / 15)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                HStack(alignment: .center, spacing: 1) {
                    Icon(name: .audioFile, size: 9)
                        .offset(y: 1)
                        .allowsHitTesting(false)

                    Text(subTitle)
                        .font(Constants.font.r12)
                        .lineLimit(1)
                }

                Spacer()

                HSeparatorView(horizontalPadding: isSubFolder ? -1.5 * Constants.size.actionBtnSize : -Constants.size.actionBtnSize)

            }.frame(maxWidth: .infinity)

            Spacer()
                .frame(width: isSubFolder ? Constants.size.actionBtnSize / 2 : 0)

            Icon(name: selected ? .checkBoxSelected : .checkBox, size: 14)
                .allowsHitTesting(false)
                .frame(width: Constants.size.actionBtnSize)
        }
        .frame(height: Constants.size.folderListCellHeight)
        .background(selected ? themeObservable.theme.listCellBg.color : themeObservable.theme.transparent.color)
        .foregroundColor(selected ? themeObservable.theme.selectedText.color : themeObservable.theme.text.color)
        .onTapGesture {
            selected.toggle()
        }
    }
}
