//
//  SearchBarView.swift
//  Pree
//
//  Created by 이유현 on 8/3/25.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var isExpanded: Bool
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
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    isExpanded = false
                    searchText = ""
                }
                isFocused = false
            }){
                Image("search_cancel")
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                
            } // : Button
            
        } // HStack
        .background(Color.white)
        .cornerRadius(20)
        .applyShadowStyle()
        .padding(.bottom, 20)
        .onAppear {
            if isExpanded {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.isFocused = true
                }
            }
        } // : onAppear
        .onChange(of: isExpanded) { newValue in
            if !newValue {
                isFocused = false
            }
        }
    }
}


#Preview {
    SearchBarView(searchText: .constant(""), isExpanded: .constant(true))
}
