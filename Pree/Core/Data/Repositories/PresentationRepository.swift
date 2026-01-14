//
//  PresentationRepositoryImpl.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

struct PresentationRepository: PresentationRepositoryProtocol {
    
    let apiService: APIServiceProtocol
    
    
    func fetchPresentations() async throws -> [Presentation] {
        let presentaions = try await apiService.fetchPresentations()
        
        // TODO: DTO로 변경
        return presentaions
    }
    
    func createNewPresentation(request: CreatePresentationRequest) async throws -> Presentation {
        let dto = CreatePresentationRequestMapper.toDTO(request)
        let response = try await apiService.createPresentation(request: dto)
        let newPresentation: Presentation = PresentationMapper.toEntity(response)
        return newPresentation
    }
}
