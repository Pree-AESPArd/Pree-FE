//
//  PracticeResultViewModel.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import Foundation

final class PracticeResultViewModel: ObservableObject {
    @Published var practiceTitle: String = "1번째 연습"
    @Published var option: MoreOption? = nil
    @Published var score: Double = 88
    
    var itemNameList : [String] = ["발표 시간", "말의 빠르기", "목소리 크기", "발화 지연 표현 횟수", "불필요한 공백 횟수", "시선 처리"]
    var progressScores: [Double] = [97, 97, 97, 40, 79, 30]
    
    //드롭다운 열렸을 경우 보여주는 값
    var evaluationList : [String] = ["내가 입력한 발표 시간", "발표에 적절한 SPM", "발표에 적절한 목소리 데시벨", "나의 발화 지연 횟수", "나의 불필요한 공백 횟수", "관객을 바라본 시선의 비율"]
    var myEvaluationlList : [String] = ["영상 발표 시간", "나의 SPM", "나의 목소리 데시벨"]
    
    //hep 버튼 텍스트
    var helpText : [String] = ["설정한 발표시간보다 부족하거나\n초과되었는지를 측정해요","SPM(Syllables per minute)은 \n말의 속도를 나타내는 단위에요.\n가장 이해하기 쉬운 속도를 기준으로 설정했어요", "마이크를 사용하거나\n작은공간에서의 발표를\n기준으로 측정한 점수에요", "“음..”, “어..”와 같은 표현을\n발화 지연 표현이라고 해요", "3초 이상의 불필요한\n공백을 감지해요", "전체 영상 중 화면을\n바라본 비율을 측정해요 "]
}
