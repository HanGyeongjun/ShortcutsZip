//
//  ReadShortcutHeaderView.swift
//  HappyAnding
//
//  Created by KiWoong Hong on 2022/10/24.
//

import SwiftUI

struct ReadShortcutHeaderView: View {
    @Environment(\.loginAlertKey) var loginAlerter
    @EnvironmentObject var shortcutsZipViewModel: ShortcutsZipViewModel
    
    @AppStorage("useWithoutSignIn") var useWithoutSignIn: Bool = false
    
    @Binding var shortcut: Shortcuts
    @Binding var isMyLike: Bool
    
    @State var userInformation: User? = nil
    @State var numberOfLike = 0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                
                icon
                
                Spacer()
                
                likeButton
                
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("\(shortcut.title)")
                    .shortcutsZipTitle1()
                    .foregroundColor(Color.gray5)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("\(shortcut.subtitle)")
                    .shortcutsZipBody1()
                    .foregroundColor(Color.gray3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            UserNameCell(userInformation: userInformation, gradeImage: shortcutsZipViewModel.fetchShortcutGradeImage(isBig: false, shortcutGrade: shortcutsZipViewModel.checkShortcutGrade(userID: userInformation?.id ?? "!")))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .onAppear() {
            shortcutsZipViewModel.fetchUser(userID: shortcut.author,
                                            isCurrentUser: false) { user in
                userInformation = user
            }
            numberOfLike = shortcut.numberOfLike
        }
        .onDisappear { self.shortcut.numberOfLike = numberOfLike }
    }
    
    // MARK: 단축어 아이콘
    var icon: some View {
        VStack {
            Image(systemName: shortcut.sfSymbol)
                .mediumShortcutIcon()
                .foregroundColor(Color.textIcon)
        }
        .frame(width: 52, height: 52)
        .background(Color.fetchGradient(color: shortcut.color))
        .cornerRadius(8)
    }
    
    // MARK: 좋아요 버튼
    var likeButton: some View {
        Text("\(isMyLike ? Image(systemName: "heart.fill") : Image(systemName: "heart")) \(numberOfLike)")
            .shortcutsZipBody2()
            .padding(10)
            .foregroundColor(isMyLike ? Color.textIcon : Color.gray4)
            .background(isMyLike ? Color.shortcutsZipPrimary : Color.gray1)
            .cornerRadius(12)
            .onTapGesture {
                if !useWithoutSignIn {
                    isMyLike.toggle()
                    //화면 상의 좋아요 추가, 취소 기능 동작
                    numberOfLike += isMyLike ? 1 : -1
                } else {
                    loginAlerter.isPresented = true
                }
            }
    }
}
