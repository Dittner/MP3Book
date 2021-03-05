//
//  ContentView.swift
//  MP3Book
//
//  Created by Alexander Dittner on 01.02.2021.
//

import SwiftUI

struct LibraryView: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var themeObservable = ThemeObservable.shared

    var body: some View {
        VStack(alignment: .center, spacing: -20) {
            NavigationBar {
                HStack {
                    TextButton(text: "Cancel", textColor: themeObservable.theme.tint.color, font: Constants.font.r14) {
                        LibraryVM.shared.cancel()
                    }

                    Spacer()

                    Text("Library").bold()
                        .font(Constants.font.b16)
                        .foregroundColor(themeObservable.theme.tint.color)
                        .offset(x: -5)

                    Spacer()

                    TextButton(text: "Done", textColor: themeObservable.theme.tint.color, font: Constants.font.b14) {
                        LibraryVM.shared.apply()
                    }
                }.padding()
            }.navigationBarShadow()

            LibraryContent()
                .edgesIgnoringSafeArea(.bottom)
        }
    }
}

struct LibraryContent: View {
    @ObservedObject var vm = LibraryVM.shared
    @ObservedObject var themeObservable = ThemeObservable.shared

    var body: some View {
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

                        HSeparatorView(horizontalPadding: -50)

                        ForEach(vm.wrappedFolders) { wrappedFolder in
                            WrapperFolderCell(w: wrappedFolder)
                        }

                        if vm.wrappedPlaylists.count > 0 {
                            Text("Media Library")
                                .font(Constants.font.r11)
                                .lineLimit(1)
                                .foregroundColor(themeObservable.theme.text.color)
                                .frame(height: 20, alignment: .center)

                            HSeparatorView(horizontalPadding: -50)

                            ForEach(vm.wrappedPlaylists) { wrappedPlaylist in
                                WrapperPlaylistCell(w: wrappedPlaylist)
                            }
                        }
                    }
                }
            }
            .clipped()
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
        subTitle = String(w.data.files.count) + " files" + ", " + DateTimeUtils.secToHHMMSS(w.data.totalDuration)
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
        subTitle = String(w.data.files.count) + " files" + ", " + DateTimeUtils.secToHHMMSS(w.data.totalDuration)
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
            Image("folder")
                .renderingMode(.template)
                .allowsHitTesting(false)
                .frame(width: isSubFolder ? 75 : 50)

            VStack(alignment: .center, spacing: 4) {
                Spacer()

                Text(title)
                    .font(Constants.font.r15)
                    .minimumScaleFactor(12 / 15)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(subTitle)
                    .font(Constants.font.r12)
                    .lineLimit(1)

                Spacer()

                HSeparatorView(horizontalPadding: -50)

            }.frame(maxWidth: .infinity)

            Spacer()
                .frame(width: isSubFolder ? 25 : 0)

            Image(selected ? "checkBoxSelected" : "checkBox")
                .renderingMode(.template)
                .allowsHitTesting(false)
                .frame(width: 50)
        }
        .frame(height: Constants.size.folderListCellHeight)
        .background(selected ? themeObservable.theme.listCellBg.color : themeObservable.theme.transparent.color)
        .foregroundColor(selected ? themeObservable.theme.selectedText.color : themeObservable.theme.text.color)
        .onTapGesture {
            selected.toggle()
        }
    }
}
