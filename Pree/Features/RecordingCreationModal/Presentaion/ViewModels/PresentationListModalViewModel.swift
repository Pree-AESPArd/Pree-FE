//
//  PresentationListModalViewModel.swift
//  Pree
//
//  Created by KimDogyung on 9/5/25.
//

import Foundation

class PresentationListModalViewModel: ObservableObject {
    
    @Published var selectedPresentaion: Presentation?
    @Published var isValid: Bool = false
    
    
    func validate() {
        isValid = selectedPresentaion != nil
    }
    
}
