//
//  ShortcutsListView.swift
//  HappyAnding
//
//  Created by KiWoong Hong on 2022/11/05.
//

import SwiftUI

struct ShortcutsListView: View {
    
    @EnvironmentObject var shortcutsZipViewModel: ShortcutsZipViewModel
    @Binding var shortcuts:[Shortcuts]
    @State var navigationTitle = ""
    
    var categoryName: Category?
    var sectionType: SectionType?
    
    var body: some View {
        ScrollView {
            
            scrollHeader
            
            LazyVStack {
                ForEach(Array(shortcuts.enumerated()), id: \.offset) { index, shortcut in
                    NavigationLink(destination: ReadShortcutView(shortcut: shortcut, shortcutID: shortcut.id)) {
                        ShortcutCell(shortcut: shortcut,
                                     rankNumber: sectionType == .download ? index + 1 : -1)
                        .listRowInsets(EdgeInsets())
                        .listRowSeparator(.hidden)
                        .onAppear {
                            print(shortcuts.count)
                            if shortcuts.last == shortcut && shortcuts.count % 10 == 0 {
                                // TODO: sectionType에 따라서 요청함수 다르거 해줘야 함
                                switch self.sectionType {
                                case .download:
                                    shortcutsZipViewModel.fetchShortcutLimit(orderBy: "numberOfDownload") { newShortcuts in
                                        shortcuts.append(contentsOf: newShortcuts)
                                    }
                                case .popular:
                                    shortcutsZipViewModel.fetchShortcutLimit(orderBy: "numberOfLike") { newShortcuts in
                                        shortcuts.append(contentsOf: newShortcuts)
                                    }
                                case .myShortcut, .myLovingShortcut, .myDownloadShortcut: print("my goodgoodgood")
                                default: // 카테고리일 경우
                                    if let categoryName {
                                        shortcutsZipViewModel.fetchCategoryShortcutLimit(category: categoryName.rawValue, orderBy: "numberOfDownload") { newShortcuts in
                                            shortcuts.append(contentsOf: newShortcuts)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle((categoryName == nil ? "" : categoryName?.translateName())!)
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.Background)
            .onAppear {
                if self.shortcuts.count == 0 {
                    if let categoryName {
                        self.shortcutsZipViewModel.fetchCategoryShortcutLimit(category: categoryName.rawValue, orderBy: "numberOfDownload") { newShortcuts in
                            self.shortcuts.append(contentsOf: newShortcuts)
                        }
                    }
                }
            }
    }
    
    var scrollHeader: some View {
        VStack {
            if let categoryName {
                Text(categoryName.fetchDescription())
            } else {
                if let sectionType {
                    Text(sectionType.description)
                }
            }
        }
        .foregroundColor(.Gray5)
        .Body2()
        .padding(16)
        .frame(maxWidth: .infinity, alignment: sectionType == .download ? .center : .leading)
        .background(
            Rectangle()
                .foregroundColor(Color.Gray1)
                .cornerRadius(12)
        )
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
    }
}
