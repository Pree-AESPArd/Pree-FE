//
//  ExpandableReportItemView.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import SwiftUI

struct ExpandableReportItemView: View {
    let item: String
    let progressScore: Double
    let index: Int
    
    @State private var isExpanded: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 고정된 헤더 영역 (제목 + 프로그레스바 + 드롭다운 버튼)
            headerSection
                .background(.white)
            
            // 확장 가능한 상세 컨텐츠 영역
            if isExpanded {
                detailSection
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),  // 위에서 아래로 나타나는 애니메이션
                        removal: .opacity.combined(with: .move(edge: .top))     // 위로 사라지는 애니메이션
                    ))
            }
        }
        .padding(.horizontal, 16)
        .background(Color.white)
        .cornerRadius(20)
        .applyShadowStyle()
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .zIndex(isExpanded ? 1 : 0) // 확장된 아이템이 위에 표시되도록
    }
    
    // MARK: - Header Section (고정 영역)
    /// 리포트 아이템의 헤더 부분 - 제목, 프로그레스바, 드롭다운 버튼을 포함
    private var headerSection: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                Text("\(item)")
                    .foregroundColor(Color.textGray)
                    .font(.pretendardMedium(size: 14))
                    .padding(.top, 14)
                    .padding(.bottom, 2)
                    
                Text("\(item)")
                    .foregroundColor(Color.black)
                    .font(.pretendardMedium(size: 14))
                    .padding(.bottom, 8)
                
                ProgressView(value: progressScore/100)
                    .progressViewStyle(CustomLinearProgressStyle(
                        score: Int(progressScore),
                        trackColor: Color.progressBarGray,
                        progressColor: Color(colorForScore(progressScore/100)),
                        height: 24,
                        cornerRadius: 8,
                        width: 280
                    ))
                    .padding(.bottom, 14)
                
            } // :VStack
            
            Spacer()
            
            // 드롭다운 토글 버튼
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                Image(isExpanded ? "dropdown_up" : "dropdown_down")
                    .frame(maxHeight: .infinity)
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            }
            
        } // : HStack
    }
    
    // MARK: - Detail Section (확장 영역)
    /// 드롭다운이 열렸을 때 표시되는 상세 정보 영역
    private var detailSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            
            ForEach(getDetailContent(for: item), id:\.self){ str in
                HStack(spacing: 0) {
                    Text(str)
                        .foregroundColor(Color.textGray)
                        .font(.pretendardMedium(size: 14))
                    
                    Spacer()
                    
                    Text("결과값")
                        .foregroundColor(.black)
                        .font(.pretendardMedium(size: 14))
                }//: HStack
                
            } // :ForEach
            
        } // : VStack
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    // MARK: - Helper Methods
    /// 각 아이템에 대한 상세 내용을 반환하는 헬퍼 메서드
    private func getDetailContent(for item: String) -> [String] {
        switch item {
        case "발표 시간":
            return ["내가 입력한 발표 시간","영상 발표 시간"]
        case "말의 빠르기":
            return ["발표에 적절한 SPM", "나의 SPM"]
        case "목소리 크기":
            return ["발표에 적절한 목소리 데시벨", "나의 목소리 데시벨"]
        case "발화 지연 표현 횟수":
            return ["나의 발화 지연 횟수"]
        case "불필요한 공백 횟수":
            return ["나의 불필요한 공백 횟수"]
        case "시선 처리":
            return ["관객을 바라본 시선의 비율"]
        default:
            return []
        }
    }
}
