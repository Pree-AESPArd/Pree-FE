//
//  AddNewPresentationModalViewModel.swift
//  Pree
//
//  Created by KimDogyung on 8/22/25.
//

import SwiftUI

class AddNewPresentationModalViewModel: ObservableObject {
    @Published var presentaion: Presentation = Presentation()
   
    @Published var titleText: String = ""
    @Published var minMinitues: String = ""
    @Published var maxMinitues: String = ""
    
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
