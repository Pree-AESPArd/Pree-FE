//
//  standardModalView.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import SwiftUI

struct standardModalView: View {
    @EnvironmentObject private var modalManager: ModalManager
    
    var body: some View {
        VStack(alignment: .leading,spacing: 0) {
            
            Spacer()
            
            Button(action:{
                modalManager.hideModal()
            }){
                Image("x_close")
                    .padding(.horizontal,8)
                    .padding(.bottom, 8)
            }
            .padding(.leading, 16)
            
            VStack(alignment: .leading, spacing:0) {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        
                        Text("Pree 평가 항목 및 감점 기준")
                            .foregroundColor(Color.textTitle)
                            .font(.pretendardSemiBold(size: 20))
                            .padding(.top, 49)
                            .padding(.bottom, 4)
                        
                        Text("Pree는 발표 연습 결과를 총점 100점 만점으로 평가합니다.\n총 점수는 다음 6가지 항목의 점수를 더하여 산출됩니다.")
                            .foregroundColor(Color.textGray)
                            .font(.pretendardMedium(size: 14))
                            .padding(.bottom, 16)
                        
                        ForEach(Array(evaluationItems.enumerated()), id: \.offset){ index, item in
                            VStack(alignment: .leading, spacing: 0) {
                                HStack(alignment: .top, spacing: 5) {
                                    Text("\(item)")
                                        .foregroundColor(Color.primary)
                                        .font(.pretendardMedium(size: 14))
                                    
                                    Text("20점")
                                        .foregroundColor(Color.primary)
                                        .font(.pretendardMedium(size: 12))
                                        .padding(.vertical, 2)
                                        .padding(.horizontal, 6)
                                        .background(Color.white)
                                        .cornerRadius(20)
                                        .applyShadowStyle()
                                    
                                    Spacer()
                                    
                                } // :HStack
                                .padding(.bottom, 8.5)
                                
                                Text("\(evaluationDescriptions[index])")
                                    .foregroundColor(Color.black)
                                    .font(.pretendardMedium(size: 14))
                                    .padding(.bottom, 4)
                                
                                Text("\(evaluationExamples[index])")
                                    .foregroundColor(Color.textGray)
                                    .font(.pretendardMedium(size: 12))
                                    .padding(.bottom, 4)
                                
                            } // : VStack
                            .padding(16)
                            .background(Color.mainBackground)
                            .cornerRadius(20)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.blue, lineWidth: 1)
                            )
                            
                        }// : VStack
                        .padding(.bottom, 8)
                    }// : foreach
                    
                } // : ScrollView
            } // :VStack
            .frame(height: 607)
            .padding(.horizontal, 16)
            .background(Color.white)
            .cornerRadius(20)
            .padding(.horizontal, 16)
            
            Spacer()
            Spacer()
            
        } // : VStack
    }
    
    // text array
    let evaluationItems: [String] = [
        "발표 시간 분석",
        "말의 속도 분석",
        "목소리 크기 분석",
        "시선 처리 비율 분석",
        "발화 지연 표현 분석",
        "불필요한 공백 분석"
    ]
    
    let evaluationDescriptions: [String] = [
        "설정 시간보다 부족하거나 초과된 경우, 3초당 1점 감점",
        "적정 속도는 130~150 WPM(Words Per Minute)\n이 범위를 벗어나면, 5 WPM당 7점 감점",
        "적정 크기는 65~70 dB\n이 범위를 벗어나면, 1dB당 5점 감점",
        "카메라 응시 비율이 80% 미만일 경우, 1%당 5점 감점",
        "“음”, “어”와 같은 발화 지연 표현 1회당 5점 감점",
        "3~4.9초의 공백일 경우, 1회당 2점 감점\n5초 이상의 공백일 경우, 1회당 5점 감점"
    ]
    
    let evaluationExamples: [String] = [
        "ex. 설정한 시간과 차이가 6초면 2점 감점",
        "ex. 125 WPM은 7점 감점",
        "ex. 63 dB이면 10점 감점",
        "ex. 75% 응시 시 25점 감점",
        "ex. 3회 사용 시 15점 감점",
        "ex. 3.5초 공백 2번, 5초 공백 1번이면 9점 감점"
    ]
    
}

#Preview {
    standardModalView()
        .environmentObject(ModalManager.shared)
}
