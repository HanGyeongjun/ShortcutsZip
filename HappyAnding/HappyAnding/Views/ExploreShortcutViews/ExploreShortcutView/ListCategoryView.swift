//
//  ListCategoryView.swift
//  HappyAnding
//
//  Created by 이지원 on 2022/10/25.
//

import SwiftUI

struct ListCategoryView: View {
    
    private let gridLayout = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        
        ZStack(alignment: .top) {
            Color.Background
                .ignoresSafeArea()
            
            VStack {
                LazyVGrid(columns: gridLayout, spacing: 12) {
                    ForEach(Category.allCases, id: \.self) { item in
                        
                        NavigationLink(destination: ListShortcutView(categoryName: item)) {
                            
                            Text(item.rawValue)
                                .Body2()
                                .tag(item)
                                .foregroundColor(Color.Gray3)
                                .frame(maxWidth: UIScreen.main.bounds.size.width * 0.5,
                                       minHeight: UIScreen.main.bounds.size.height * 0.7 * 0.08)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.Gray3, lineWidth: 1)
                                )
                        }
                        .padding(10)
                    }
                }
                .padding(.horizontal, 6)
                            Spacer().frame(maxWidth: .infinity)
            }
        }
        .frame(maxHeight: .infinity)
    }
}


struct ListCategoryView_Previews: PreviewProvider {
    static var previews: some View {
        ListCategoryView()
    }
}
