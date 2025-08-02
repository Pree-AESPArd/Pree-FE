//
//  CustomLinearProgressStyle.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import SwiftUI

struct CustomLinearProgressStyle: ProgressViewStyle {
    var score: Int = 0
    var trackColor: Color = Color.gray.opacity(0.3)
    var progressColor: Color = Color.blue
    var height: CGFloat = 8
    var cornerRadius: CGFloat = 4
    var width: CGFloat = 280
    
    func makeBody(configuration: Configuration) -> some View {
        let fraction = CGFloat(configuration.fractionCompleted ?? 0)
        
        return ZStack(alignment: .leading) {
            // 전체 트랙
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(trackColor)
                .frame(width: width, height: height)
            
            // 진행된 부분 (길이만 유동적으로 변화)
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(progressColor)
                .frame(width: width * fraction, height: height)
            
            Text("\(score)점")
                .foregroundColor(.white)
                .font(.pretendardMedium(size: 16))
                .offset(x:7)
        }
        .frame(width: width, height: height)
    }
}
