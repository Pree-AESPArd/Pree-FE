//
//  PracticeResult.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

struct PracticeResult: View {
    @StateObject var vm: PracticeResultViewModel
    @Binding var showPracticeResult: Bool
    
    var body: some View {
        VStack(alignment: .leading,spacing:0){
            //MARK: - header
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading,spacing:0){
                    
                    //MARK: - video player
                    
                    //MARK: - total score
                    
                    //MARK: - report result
                    
                    //MARK: - show evaluation criteria
                } // : VStack
                .padding(.horizontal, 16)
                .padding(.bottom, 300)
            }// : ScrollView
        }// : VStack
        .background(Color.mainBackground.ignoresSafeArea())
    }
}

#Preview {
    let vm = AppDI.shared.makePracticeResultViewModel()
    PracticeResult(vm:vm, showPracticeResult: .constant(false))
}
