//
//  SearchProjectsUseCase.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

protocol SearchProjectsUseCaseProtocol {
    func execute(query: String) async throws -> [Presentation]
}

final class SearchProjectsUseCase: SearchProjectsUseCaseProtocol {
    private let repository: PresentationRepositoryProtocol
    
    init(repository: PresentationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(query: String) async throws -> [Presentation] {
        // 빈 검색어 예외 처리 (필요 시)
        guard !query.isEmpty else { return [] }
        return try await repository.searchProjects(query: query)
    }
}
