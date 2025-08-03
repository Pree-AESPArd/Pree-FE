//
//  SearchBarView.swift
//  Pree
//
//  Created by 이유현 on 8/3/25.
//

import SwiftUI

struct SearchBarView: View {
    @State private var searchText: String = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            TextField("연습 목록을 검색하세요", text: $searchText)
                .font(.pretendardMedium(size: 16))
                .padding(.vertical, 11)
                .padding(.leading, 16)
                .background(Color.white)
                .cornerRadius(10)
                .focused($isFocused)
            
            Spacer()
            
            Button(action:{
                isFocused = false
                searchText = ""
            }){
                Image("search_cancel")
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                
            } // : Button
        } // HStack
        .background(Color.white)
        .cornerRadius(20)
        .applyShadowStyle()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isFocused = true
            }
        } // : onAppear
    }
}


#Preview {
    SearchBarView()
}
