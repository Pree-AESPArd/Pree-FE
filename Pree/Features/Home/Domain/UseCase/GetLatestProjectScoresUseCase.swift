//
//  GetLatestProjectScoresUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

protocol GetLatestProjectScoresUseCaseProtocol {
    func execute() async throws -> ProjectAverageScores
}

final class GetLatestProjectScoresUseCase: GetLatestProjectScoresUseCaseProtocol {
    private let repository: PresentationRepositoryProtocol
    
    init(repository: PresentationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> ProjectAverageScores {
        return try await repository.fetchLatestProjectScores()
    }
}
