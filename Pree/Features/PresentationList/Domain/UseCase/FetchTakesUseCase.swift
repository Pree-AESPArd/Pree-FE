//
//  FetchTakesUseCase.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//


import Foundation

protocol FetchTakesUseCaseProtocol {
    func execute(presentationId: String) async throws -> [Take]
}

final class FetchTakesUseCase: FetchTakesUseCaseProtocol {
    
    private let repository: TakeRepositoryProtocol
    
    init(repository: TakeRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(presentationId: String) async throws -> [Take] {
        return try await repository.fetchTakes(presentationId: presentationId)
    }
}

