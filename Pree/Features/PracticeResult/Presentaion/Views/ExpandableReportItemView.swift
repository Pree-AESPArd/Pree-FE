//
//  ExpandableReportItemView.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import SwiftUI

/// 확장 가능한 리포트 아이템 뷰
/// - 드롭다운 버튼을 클릭하면 아래로 내려오는 애니메이션과 함께 상세 컨텐츠 표시
/// - 올라가는 버튼으로 닫기 가능
struct ExpandableReportItemView: View {
    let item: String
    let progressScore: Int
    let index: Int
    let detailValue: String
    
    @State private var isExpanded: Bool = false
    @State private var showHelpView: Bool = false
    
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
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .zIndex(isExpanded ? 1 : 0) // 확장된 아이템이 위에 표시되도록
        .overlay{
            if showHelpView {
                helpOverlay
                    .offset(x: getHelpOffset(for: item).x, y: getHelpOffset(for: item).y)
            }
        }
        .zIndex(showHelpView ? 2 : (isExpanded ? 1 : 0)) // Help 뷰가 가장 위에 표시되도록
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
                
                ProgressView(value: Double(progressScore), total: 100.0)
                    .progressViewStyle(CustomLinearProgressStyle(
                        score: Int(progressScore),
                        trackColor: Color.progressBarGray,
                        progressColor: Color(colorForScore(Double(progressScore))),
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
                    if !isExpanded {
                        showHelpView = false
                    } // : if
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
            let contents = getDetailContent(for: item)
            ForEach(Array(contents.enumerated()), id: \.offset) { index, str in
                detailRow(index: index, content: str)
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    @ViewBuilder
    private func detailRow(index: Int, content: String) -> some View {
        HStack(spacing: 0) {
            Text(content)
                .foregroundColor(Color.textGray)
                .font(.pretendardMedium(size: 14))
            
            if index == 0 {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showHelpView.toggle()
                    }
                }) {
                    Image("help")
                        .padding(.horizontal, 5.33)
                }
            }
            
            Spacer()
            
            Text(getDisplayValue(for: item, labelIndex: index))
                .foregroundColor(.black)
                .font(.pretendardMedium(size: 14))
        }
    }
    
    // MARK: - Help Overlay
    /// Help 아이콘을 클릭했을 때 표시되는 도움말 뷰
    private var helpOverlay: some View {
        
        // 도움말 팝업
        VStack(alignment: .leading, spacing: 0) {
            
            Text(getHelpContent(for: item))
                .font(.pretendardMedium(size: 14))
                .foregroundColor(Color.primary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal,12)
        .padding(.vertical, 8)
        .background(Color.helpBgBlue)
        .cornerRadius(20)
        .applyShadowStyle()
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
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
    
    private func getDisplayValue(for item: String, labelIndex: Int) -> String {
        switch item {
        case "발표 시간":
            return labelIndex == 0 ? "3:00" : detailValue // 설정 시간은 예시
        case "말의 빠르기":
            return labelIndex == 0 ? "300 ~ 350" : detailValue
        case "목소리 크기":
            return labelIndex == 0 ? "60 ~ 70dB" : detailValue
        case "발화 지연 표현 횟수", "불필요한 공백 횟수", "시선 처리":
            return detailValue
        default:
            return "-"
        }
    }
    
    /// 각 아이템에 대한 도움말 내용을 반환하는 헬퍼 메서드
    private func getHelpContent(for item: String) -> String {
        switch item {
        case "발표 시간":
            return "설정한 발표시간보다 부족하거나\n초과되었는지를 측정해요"
        case "말의 빠르기":
            return "SPM(Syllables per minute)은 \n말의 속도를 나타내는 단위에요.\n가장 이해하기 쉬운\n속도를 기준으로 설정했어요"
        case "목소리 크기":
            return "마이크를 사용하거나\n작은공간에서의 발표를\n기준으로 측정한 점수에요"
        case "발화 지연 표현 횟수":
            return "“음..”, “어..”와 같은 표현을\n발화 지연 표현이라고 해요"
        case "불필요한 공백 횟수":
            return "3초 이상의 불필요한\n공백을 감지해요"
        case "시선 처리":
            return "전체 영상 중 화면을\n바라본 비율을 측정해요"
        default:
            return ""
        }
    }
    
    /// 각 아이템에 대한 help 뷰의 offset 값을 반환하는 헬퍼 메서드
    private func getHelpOffset(for item: String) -> (x: CGFloat, y: CGFloat) {
        switch item {
        case "발표 시간":
            return (x: 30, y: -5)
        case "말의 빠르기":
            return (x: 25, y: -25)
        case "목소리 크기":
            return (x: 50, y: -15)
        case "발화 지연 표현 횟수":
            return (x: 25, y: 5)
        case "불필요한 공백 횟수":
            return (x: 30, y: 5)
        case "시선 처리":
            return (x: 40, y: 5)
        default:
            return (x: 0, y: 0)
        }
    }
}
