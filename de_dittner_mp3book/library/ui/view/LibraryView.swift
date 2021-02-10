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
                .navigationBarHidden(false)
                .navigationViewTheme(themeObservable.theme)
                .navigationBarTheme(themeObservable.theme)
                .edgesIgnoringSafeArea(.bottom)
                
        }.onAppear{
            vm.loadFiles()
        }
    }
}

struct LibraryContent: View {
    @Environment(\.presentationMode) var presentation
    @ObservedObject var vm: LibraryVM

    var body: some View {
        if vm.isLoading {
            ActivityIndicator(isAnimating: $vm.isLoading)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 1) {
                    ForEach(vm.folders) { folder in
                        FolderCell(data: folder)
                    }
                }
            }
            .clipped()
        }
    }
}

struct FolderCell: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    @ObservedObject var data: FolderWrapper
    let title: String
    let subTitle: String

    init(data: FolderWrapper) {
        self.data = data
        title = data.folder.title
        subTitle = String(data.folder.files.count) + " files" + ", " + DateTimeUtils.secToHHMMSS(data.folder.totalDuration)
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            Image("folder")
                .renderingMode(.template)
                .allowsHitTesting(false)
                .frame(width: 50)
                

            VStack {
                Spacer()
                
                Text(title)
                    .font(Font.custom(.helveticaNeue, size: 17))
                    .minimumScaleFactor(12 / 17)
                    .lineLimit(1)

                Text(subTitle)
                    .font(Font.custom(.helveticaNeue, size: 12))
                    .lineLimit(1)

                Spacer()
                
                Separator()
                    .stroke(lineWidth: 0.5)
                    .fill(themeObservable.theme.separator.color)
                    .padding(.horizontal, -50)

            }.frame(maxWidth: .infinity)

            Image(data.selected ? "checkBoxSelected" : "checkBox")
                .renderingMode(.template)
                .allowsHitTesting(false)
                .frame(width: 50)
        }
        .frame(height: 50)
        .background(data.selected ? themeObservable.theme.listCellBg.color : Color.clear)
        .foregroundColor(data.selected ? themeObservable.theme.selectedText.color : themeObservable.theme.text.color)
        .onTapGesture {
            data.selected.toggle()
        }
    }
}
