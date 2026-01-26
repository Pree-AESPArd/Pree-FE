//
//  PresentationListModalViewModel.swift
//  Pree
//
//  Created by KimDogyung on 9/5/25.
//

import Foundation
import Combine

class PresentationListModalViewModel: ObservableObject {
    
    @Published var presentations: [Presentation] = []
    @Published var selectedPresentaion: Presentation?
    @Published var isValid: Bool = false // 특정 발표가 선택이 되었는지 확인 하는 용도
    
    private let presentationRepository: PresentationRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    func validate() {
        isValid = selectedPresentaion != nil
    }
    
    init(presentationRepository: PresentationRepositoryProtocol) {
        self.presentationRepository = presentationRepository
        
        if let repo = presentationRepository as? PresentationRepository {
            repo.presentationsPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.presentations, on: self)
                .store(in: &cancellables)
        }
        
        // 모달 켜질 때 최신 데이터 한 번 더 당겨오기
        Task {
            try? await presentationRepository.fetchPresentations(sortOption: "latest")
        }
    }
    
}
