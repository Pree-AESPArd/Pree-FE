//
//  OverlayView.swift
//  Pree
//
//  Created by KimDogyung on 7/29/25.
//

// 영상촬영 화면 위에 보이는 버튼과 안내문구 요소를 보여주기 위한 뷰
// 화면 녹화시 이 화면은 유저에게는 보이지만 화면 녹화에는 녹화되지 않음

import SwiftUI

struct OverlayView: View {
    var body: some View {
        VStack(spacing: 0) {
            
            descriptionText
            
            Spacer()
            
            PrimaryButton(title: "촬영 시작하기")
        }
    }
    
    
    private var descriptionText: some View {
        Text("아이트래킹을 위해\n 얼굴에 프레임을 맞춰서 촬영해주세요")
            .font(.pretendardMedium(size: 14))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.center)
            .padding(8)
            .background(.white)
            .cornerRadius(8)
    }
    
}


