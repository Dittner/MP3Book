//
//  BookList.swift
//  MP3Book
//
//  Created by Alexander Dittner on 07.02.2021.
//

import SwiftUI

struct BookListView: View {
    @ObservedObject var themeObservable = ThemeObservable.shared
    @ObservedObject var vm = BookListVM.shared

    var body: some View {
        NavigationView {
            VStack {
                Text("Content").foregroundColor(Color.black)
                    .background(Color.red)
                Spacer()
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    IconButton(iconName: "switchTheme", iconColor: themeObservable.theme.tint.color) {
                        self.themeObservable.switchTheme()
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Playlist").bold()
                        .font(Font.m3b.navigationTitle)
                        .foregroundColor(themeObservable.theme.tint.color)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    IconButton(iconName: "add", iconColor: themeObservable.theme.tint.color) {
                        self.vm.isModalSheetShown = true
                    }
                }
            }
            // .navigationViewStyle(StackNavigationViewStyle())
            // .listStyle(PlainListStyle())
            .navigationViewTheme(themeObservable.theme)
            .navigationBarTheme(themeObservable.theme)

            .sheet(isPresented: $vm.isModalSheetShown, onDismiss: {
                vm.isModalSheetShown = false
                print("DISMISSED")
            }) {
                LibraryView()
            }
        }
    }
}
