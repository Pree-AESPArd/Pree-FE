//
//  ContentView.swift
//  Pree
//
//  Created by KimDogyung on 7/24/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject var vm: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            //header
            HStack(spacing: 0){
                Image("LOGO")
                    .padding(.vertical, 12.62)
                
                Spacer()
            }
            
            // summary graph
            Text("\(vm.userName)님, 오늘도 \n프리와 함께 발표준비해요!")
                .foregroundStyle(Color.textTitle)
                .font(.pretendardBold(size: 28))
                .padding(.top, 8)
                .padding(.bottom, 16)
            
            VStack(spacing:0){
                
            }
            
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .background(Color.mainBackground)
    }
}

#Preview {
    let vm = AppDI.shared.makeHomewViewModel()
    HomeView(vm:vm)
}
