//
//  WriteCurationSetView.swift
//  HappyAnding
//
//  Created by 이지원 on 2022/10/19.
//

import SwiftUI

struct WriteCurationSetView: View {
    
    @Binding var isWriting: Bool
    
    //TODO: 데이터 모델 제작 후 해당 ObservedObject 삭제 필요.
    @ObservedObject var shortcutData = fetchData()
    
    
    @State private var numberOfSelected: Int = 0
    
    // TODO: firebase 함수로 결괏값 가져오면, 그 배열의 길이를 넣어야함!
    let firebase = FirebaseService()
    @State var shortcuts: [Shortcuts] = []
    
    @State var isSelected = [Bool](repeating: false, count: 10)
    @State var selectedShortcut: [Shortcuts] = []
    
    var body: some View {
        NavigationStack {
            VStack() {
                HStack {
                    Button(action: {
                        isWriting.toggle()
                    }, label: {
                        Text("\(Image(systemName: "chevron.left")) Back")
                            .font(.body)
                    })
                    .frame(alignment: .leading)
                    
                    Text("나의 큐레이션 만들기")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Text("\(Image(systemName: "chevron.left")) Back")
                        .frame(alignment: .trailing)
                        .foregroundColor(Color(UIColor.clear))
                }
                .padding(.top, 12)
                .padding(.horizontal, 16)
                ProgressView(value: 1, total: 2)
                    .padding(.bottom, 36)
                listHeader
                ScrollView {
                    shortcutList
                }
                
                bottomButton
            }
            .background(Color.Background)
            .onAppear() {
                firebase.fetchShortcut(model: "Shortcut") { shortcuts in
                    self.shortcuts = shortcuts
                }
            }
        }
    }
    
    ///단축어 선택 텍스트 및 카운터
    var listHeader: some View {
        HStack(alignment: .bottom) {
            Text("단축어 선택")
                .Headline()
                .foregroundColor(.Gray5)
            Text("최대 10개 선택")
                .Footnote()
                .foregroundColor(.Gray3)
            Spacer()
            Text("\(numberOfSelected)개")
                .Body2()
                .foregroundColor(.Primary)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 20)
    }
    
    ///내가 작성한, 좋아요를 누른 단축어 목록
    var shortcutList: some View {
        ForEach(Array(shortcuts.enumerated()), id: \.offset) { index, shortcut in
            CheckBoxShortcutCell(
                isShortcutTapped: isSelected[index],
                numberOfSelected: $numberOfSelected,
                selectedShortcut: $selectedShortcut,
                shortcut: shortcut
//                ,
//                color: self.shortcutData.data[index].color,
//                sfSymbol: self.shortcutData.data[index].sfSymbol,
//                name: self.shortcutData.data[index].name,
//                description: self.shortcutData.data[index].description
            )
        }
//        ForEach(0..<10, id: \.self) { index in
//            CheckBoxShortcutCell(isShortcutTapped: isSelected[index], numberOfSelected: $numberOfSelected, selectedShortcut: $selectedShortcut, color: self.shortcutData.data[index].color,
//                         sfSymbol: self.shortcutData.data[index].sfSymbol,
//                         name: self.shortcutData.data[index].name,
//                         description: self.shortcutData.data[index].description)
//        }
    }
    
    ///완료 버튼
    var bottomButton: some View {
        
        NavigationLink {
            let _ = print(shortcuts)
            WriteCurationInfoView(shortcuts: selectedShortcut, isWriting: $isWriting)
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .foregroundColor(numberOfSelected > 0 ? .Primary : .Gray1)
                    .padding(.horizontal, 16)
                    .frame(height: 52)
                Text("다음")
                    .foregroundColor(numberOfSelected > 0 ? .Background : .Gray3)
            }
        }
        .padding(.bottom, 24)
        .disabled(numberOfSelected == 0)
        
//        Button(action: {
//            //Action넣기
//            print(selectedShortcut)
//            
//        }, label: {
//            ZStack {
//                RoundedRectangle(cornerRadius: 12)
//                    .foregroundColor(numberOfSelected > 0 ? .Primary : .Gray1)
//                    .padding(.horizontal, 16)
//                    .frame(height: 52)
//                Text("완료")
//                    .foregroundColor(numberOfSelected > 0 ? .Background : .Gray3)
//            }
//        })
//        .padding(.bottom, 24)
//        .disabled(numberOfSelected == 0)
    }
}

struct WriteCurationSetView_Previews: PreviewProvider {
    static var previews: some View {
        WriteCurationSetView(isWriting: .constant(false))
    }
}
