//
//  ReadUserCurationView.swift
//  HappyAnding
//
//  Created by HanGyeongjun on 2022/10/22.
//

import SwiftUI

struct ReadUserCurationView: View {
    let firebase = FirebaseService()
    @State var authorInformation: User? = nil
    
    @State var isMyCuration: Bool = true
    @State var isWriting = false
    @State var isTappedEditButton = false
    @State var isTappedShareButton = false
    @State var isTappedDeleteButton = false
    
    let userCuration: Curation
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .bottom) {
                Color.White
                    .ignoresSafeArea(.all, edges: .all)
                    .frame(height: 371)
                
                VStack{
                    userInformation
                        .padding(.bottom, 22)
                    UserCurationCell(title: userCuration.title,
                                     subtitle: userCuration.subtitle ?? "",
                                     shortcuts: userCuration.shortcuts,
                                     curation: userCuration)
                        .padding(.bottom, 12)
                }
            }
            ForEach(Array(userCuration.shortcuts.enumerated()), id: \.offset) { index, shortcut in
                NavigationLink(destination: ReadShortcutView(shortcut: shortcut)) {
                    ShortcutCell(
//                        color: shortcut.color,
//                        sfSymbol: shortcut.sfSymbol,
//                        name: shortcut.name,
//                        description: shortcut.description,
//                        numberOfDownload: shortcut.numberOfDownload,
//                        downloadLink: shortcut.downloadLink
                        shortcut: shortcut
                    )
                    .padding(.bottom, index == userCuration.shortcuts.count - 1 ? 44 : 0)
                }
            }
        }
        .background(Color.Background.ignoresSafeArea(.all, edges: .all))
        .scrollContentBackground(.hidden)
        .edgesIgnoringSafeArea([.top])
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Menu(content: {
            if userCuration.author == firebase.currentUser() {
                myCurationMenuSection
            } else {
                otherCurationMenuSection
            }
        }, label: {
            Image(systemName: isMyCuration ? "ellipsis" : "square.and.arrow.up")
                .foregroundColor(.Gray4)
        }))
        .fullScreenCover(isPresented: $isTappedEditButton) {
            NavigationView {
                WriteCurationSetView(isWriting: $isTappedEditButton,
                                     curation: userCuration, isEdit: true)
            }
        }
    }
    
    var userInformation: some View {
        ZStack {
            HStack {
                Image(systemName: "person.fill")
                    .frame(width: 28, height: 28)
                    .foregroundColor(.White)
                    .background(Color.Gray3)
                    .clipShape(Circle())
                
                Text(authorInformation?.nickname ?? "닉네임")
                    .Headline()
                    .foregroundColor(.Gray4)
                
                Spacer()
                //TODO: 스프린트 1에서 배제 , 추후 주석 삭제 필요
                /*
                Image(systemName: "light.beacon.max.fill")
                    .Headline()
                    .foregroundColor(.Gray5)
                    .onTapGesture {
                        
                        // TODO: 신고기능 연결
                        
                        print("Tapped!")
                    }
                 */
            }
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .frame(height: 48)
                    .foregroundColor(.Gray1)
                    .padding(.horizontal, 16)
            )
        }
        .onAppear {
            firebase.fetchUser(userID: userCuration.author) { user in
                authorInformation = user
            }
        }
    }
}


extension ReadUserCurationView {
    var myCurationMenuSection: some View {
        Section {
            Button(action: {
                isTappedEditButton.toggle()
                print("ReadUserCurationView \(userCuration)")
            }) {
                Label("편집", systemImage: "square.and.pencil")
            }
            
            // TODO: 함수 구현 필요
            
            Button(action: {
                //Place something action here
            }) {
                Label("공유", systemImage: "square.and.arrow.up")
            }
            Button(action: {
                //Place something action here
            }) {
                Label("삭제", systemImage: "trash.fill")
                    .foregroundColor(Color.red)
            }
        }
    }
    
    var otherCurationMenuSection: some View {
        Button(action: {
            //Place something action here
        }) {
            Label("공유", systemImage: "square.and.arrow.up")
        }
    }
}

//struct ReadUserCurationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReadUserCurationView(userCuration: UserCuration.fetchData(number: 1)[0], nickName: "test")
//    }
//}
