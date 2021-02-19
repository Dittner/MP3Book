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
        VStack(alignment: .center, spacing: 0) {
            NavigationBar {
                HStack {
                    TextButton(text: "Cancel", textColor: themeObservable.theme.tint.color, font: Font.m3b.cancelButton) {
                        LibraryVM.shared.cancel()
                    }

                    Spacer()

                    Text("Edit  ").bold()
                        .font(Font.m3b.navigationTitle)
                        .foregroundColor(themeObservable.theme.tint.color)

                    Spacer()

                    TextButton(text: "Done", textColor: themeObservable.theme.tint.color, font: Font.m3b.applyButton) {
                        LibraryVM.shared.apply()
                    }
                }.padding()
            }

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
                LazyVStack(alignment: .center, spacing: 0) {
                    if vm.wrappedFolders.count > 0 {
                        Text("Documents")
                            .font(Font.custom(.helveticaNeue, size: 11))
                            .lineLimit(1)
                            .foregroundColor(themeObservable.theme.text.color)
                            .frame(height: 20, alignment: .center)

                        SeparatorView(horizontalPadding: -50)

                        ForEach(vm.wrappedFolders) { wrappedFolder in
                            WrapperFolderCell(w: wrappedFolder)
                        }

                        if vm.wrappedPlaylists.count > 0 {
                            Text("iPod Library")
                                .font(Font.custom(.helveticaNeue, size: 11))
                                .lineLimit(1)
                                .foregroundColor(themeObservable.theme.text.color)
                                .frame(height: 20, alignment: .center)

                            SeparatorView(horizontalPadding: -50)

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

    init(w: Wrapper<Folder>) {
        wrappedFolder = w
        title = w.data.title
        subTitle = String(w.data.files.count) + " files" + ", " + DateTimeUtils.secToHHMMSS(w.data.totalDuration)
    }

    var body: some View {
        ListCell(title: title, subTitle: subTitle, selected: $wrappedFolder.selected)
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
        ListCell(title: title, subTitle: subTitle, selected: $wrappedFolder.selected)
    }
}

struct ListCell: View {
    @ObservedObject var themeObservable = ThemeObservable.shared

    let title: String
    let subTitle: String
    @Binding var selected: Bool

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("folder")
                .renderingMode(.template)
                .allowsHitTesting(false)
                .frame(width: 50)

            VStack(alignment: .center, spacing: 2) {
                Spacer()

                Text(title)
                    .font(Font.custom(.helveticaNeue, size: 17))
                    .minimumScaleFactor(11 / 17)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)

                Text(subTitle)
                    .font(Font.custom(.helveticaNeue, size: 12))
                    .lineLimit(1)

                Spacer()

                SeparatorView(horizontalPadding: -50)

            }.frame(maxWidth: .infinity)

            Image(selected ? "checkBoxSelected" : "checkBox")
                .renderingMode(.template)
                .allowsHitTesting(false)
                .frame(width: 50)
        }
        .frame(height: 70)
        .background(selected ? themeObservable.theme.listCellBg.color : themeObservable.theme.transparent.color)
        .foregroundColor(selected ? themeObservable.theme.selectedText.color : themeObservable.theme.text.color)
        .onTapGesture {
            selected.toggle()
        }
    }
}
