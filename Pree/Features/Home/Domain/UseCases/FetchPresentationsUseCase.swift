//
//  FetchPresentationsUseCase.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

struct FetchPresentationsUseCase {
    let presentationRepository: PresentationRepository
    
    func execute() async throws -> [Presentation] {
        return try await presentationRepository.fetchPresentations()
    }
}
