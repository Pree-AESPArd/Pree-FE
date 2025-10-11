//
//  PresentationRepositoryImpl.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

struct PresentationRepositoryImpl: PresentationRepository {
    
    let apiService: APIServiceProtocol
    
    
    
    func fetchPresentations() async throws -> [Presentation] {
        let presentaions = try await apiService.fetchPresentations()
        
        // TODO: DTO로 변경
        return presentaions
    }
    
    func createPresentation(createPresentationRequest: CreatePresentationRequest) async throws -> ResponseForNewPresentation {
        let response = try await apiService.createPresentation(createPresentationRequest: createPresentationRequest)
        return response
    }
}
