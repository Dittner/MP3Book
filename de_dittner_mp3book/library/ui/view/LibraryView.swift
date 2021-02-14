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
    @ObservedObject var vm = LibraryVM.shared

    var body: some View {
        NavigationView {
            LibraryContent(vm: vm)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        TextButton(text: "Cancel", textColor: themeObservable.theme.tint.color, font: Font.m3b.cancelButton) {
                            self.presentation.wrappedValue.dismiss()
                        }
                    }

                    ToolbarItem(placement: .principal) {
                        Text("Edit")
                            .font(Font.m3b.navigationTitle)
                            .foregroundColor(themeObservable.theme.tint.color)
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        TextButton(text: "Done", textColor: themeObservable.theme.tint.color, font: Font.m3b.applyButton) {
                            self.vm.apply()
                            self.presentation.wrappedValue.dismiss()
                        }
                    }
                }
                .navigationViewTheme(themeObservable.theme)
                .navigationBarTheme(themeObservable.theme)
                .edgesIgnoringSafeArea(.bottom)

        }
        .navigationBarHidden(true)
        .onAppear {
            vm.loadFiles()
        }
    }
}

struct LibraryContent: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var vm: LibraryVM
    @ObservedObject var themeObservable = ThemeObservable.shared

    var body: some View {
        if vm.isLoading {
            ActivityIndicator(isAnimating: $vm.isLoading)
        } else {
            ScrollView {
                LazyVStack(alignment: .center, spacing: 1) {
                    if vm.wrappedFolders.count > 0 {
                        Text("Documents")
                            .font(Font.custom(.helveticaNeue, size: 11))
                            .lineLimit(1)
                            .foregroundColor(themeObservable.theme.text.color)
                            .frame(height: 20, alignment: .center)

                        SeparatorView()

                        ForEach(vm.wrappedFolders) { wrappedFolder in
                            WrapperFolderCell(w: wrappedFolder)
                        }

                        if vm.wrappedPlaylists.count > 0 {
                            Text("iPod Library")
                                .font(Font.custom(.helveticaNeue, size: 11))
                                .lineLimit(1)
                                .foregroundColor(themeObservable.theme.text.color)
                                .frame(height: 20, alignment: .center)

                            SeparatorView()

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
    @ObservedObject var wrappedFolder:Wrapper<Folder>
    let title: String
    let subTitle: String

    init(w: Wrapper<Folder>) {
        self.wrappedFolder = w
        title = w.data.title
        subTitle = String(w.data.files.count) + " files" + ", " + DateTimeUtils.secToHHMMSS(w.data.totalDuration)
        
    }
    
    var body: some View {
        ListCell(title: title, subTitle: subTitle, selected: $wrappedFolder.selected)
    }
}

struct WrapperPlaylistCell: View {
    @ObservedObject var wrappedFolder:Wrapper<Playlist>
    let title: String
    let subTitle: String

    init(w: Wrapper<Playlist>) {
        self.wrappedFolder = w
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
    @Binding var selected:Bool
    
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

                SeparatorView()

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
