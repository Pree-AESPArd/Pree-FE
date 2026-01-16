//
//  CreatePresentationUseCase.swift
//  Pree
//
//  Created by KimDogyung on 1/8/26.
//

import Foundation

class CreatePresentationUseCase {
    private let repository: PresentationRepositoryProtocol
    
    init(repository: PresentationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(request: CreatePresentationRequest) async throws -> Presentation {
        let response = try await repository.createNewPresentation(request: request)
        return response
        
    }
}
