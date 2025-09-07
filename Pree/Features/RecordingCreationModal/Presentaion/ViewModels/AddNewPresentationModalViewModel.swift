//
//  AddNewPresentationModalViewModel.swift
//  Pree
//
//  Created by KimDogyung on 8/22/25.
//

import SwiftUI

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
    
    @Published var errorMessage: ErrorMessage = ErrorMessage()

    
    func validateTitleText() {
        if titleText.count > 15 {
            errorMessage.titleTextErrorMessage = "최대 글자는 15자에요"
        }
        
        if titleText.isEmpty || titleText == "" {
            errorMessage.titleTextErrorMessage = "텍스트 필드가 비어 있습니다."
        }
    }
    
    
}
