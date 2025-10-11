//
//  CreatePresentationUseCase.swift
//  Pree
//
//  Created by KimDogyung on 10/10/25.
//

import Foundation

public final class CreatePresentationUseCase {
    
    private let presentationRepository: PresentationRepository
    
    init(presentationRepository: PresentationRepository) {
        self.presentationRepository = presentationRepository
    }
    
    func execute(CreatePresentationRequest presentation: CreatePresentationRequest) async throws -> ResponseForNewPresentation {
        do {
            let response = try await presentationRepository.createPresentation(createPresentationRequest: presentation)
            
            return response
        } catch let error {
            // TODO: 에러 정의해서 각 에러 타입별로 반환
            throw error
        }
        
        
    }
}
