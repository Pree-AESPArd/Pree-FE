//
//  AddNewPresentationModalViewModel.swift
//  Pree
//
//  Created by KimDogyung on 8/22/25.
//

import SwiftUI

enum ModalErorr {
    case textFieldEmpty
    case exceedMaxLength
    case exceedMaxTime
    case exceedMinTime
    case invalidTimeFormat
}

class AddNewPresentationModalViewModel: ObservableObject {
    //@Published var presentaion: Presentation
    
    @Published var titleText: String = ""
    @Published var minMinitue: String = "05"
    @Published var minSecond: String = "00"
    @Published var maxMinitue: String = "07"
    @Published var maxSecond: String = "00"
    @Published var showRecordingTime: Bool = false
    @Published var showScreen: Bool = false
    @Published var debugMode: Bool = false
    
    @Published var textFieldError: String? = nil
    @Published var timeError: String? = nil
    @Published var isValid: Bool = false
    
    
    func timeStringToInt() -> (minTime: Int, maxTime: Int)? {
        guard let minM = Int(minMinitue),
              let minS = Int(minSecond),
              let maxM = Int(maxMinitue),
              let maxS = Int(maxSecond) else {
            return nil // 하나라도 변환에 실패하면 nil 반환
        }
        
        let minTimeInt = (minM * 60) + minS
        let maxTimeInt = (maxM * 60) + maxS
        
        return (minTimeInt, maxTimeInt)
    }
    
    func validateTitleText() {
        textFieldError = nil
        
        // 비어있는지 먼저 확인
        guard !titleText.trimmingCharacters(in: .whitespaces).isEmpty else {
            textFieldError = "발표 제목을 입력해주세요."
            return
        }
        
        // 최대 글자 수를 확인
        if titleText.count > 15 {
            textFieldError = "최대 15자까지 입력할 수 있어요."
        }
    }
    
    func validateTimeText() {
        
        timeError = nil
        
        guard let (minTime, maxTime) = timeStringToInt() else {
            timeError = "유효한 숫자를 입력해주세요"
            return
        }
        
        if minTime >= maxTime {
            timeError = "최소시간은 최대시간을 넘을 수 없어요"
        }
        
        if maxTime > 600 {
            timeError = "최대 설정시간은 10분이에요"
        }
        
        
    }
    
    func validateForm() {
        validateTitleText()
        validateTimeText()
        
        isValid = textFieldError == nil && timeError == nil
    }
    
    
}
