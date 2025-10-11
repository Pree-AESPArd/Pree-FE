//
//  PresentationListModalViewModel.swift
//  Pree
//
//  Created by KimDogyung on 9/5/25.
//

import Foundation

class PresentationListModalViewModel: ObservableObject {
    
    @Published var selectedPresentaion: Presentation?
    @Published var isValid: Bool = false // 특정 발표가 선택이 되었는지 확인 하는 용도
    
    
    func validate() {
        isValid = selectedPresentaion != nil
    }
    
}
