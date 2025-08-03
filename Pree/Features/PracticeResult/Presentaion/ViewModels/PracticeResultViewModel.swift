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
    @Published var totalscore: Double = 88
    @Published var videoKey: String = "??"// 테스트 비디오 키
    
    var itemNameList : [String] = ["발표 시간", "말의 빠르기", "목소리 크기", "발화 지연 표현 횟수", "불필요한 공백 횟수", "시선 처리"]
    var progressScores: [Double] = [97, 97, 97, 40, 79, 30]

}
