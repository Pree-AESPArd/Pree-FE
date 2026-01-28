//
//  GetRecentScoresUseCase.swift
//  Pree
//
//  Created by KimDogyung on 1/27/26.
//

protocol GetRecentScoresUseCaseProtocol {
    func execute(presentationId: String) async throws -> [Double]
}

final class GetRecentScoresUseCase: GetRecentScoresUseCaseProtocol {
    private let repository: TakeRepositoryProtocol
    
    init(repository: TakeRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(presentationId: String) async throws -> [Double] {
        let recentScores = try await repository.fetchRecentScores(presentationId: presentationId)
        
        // 그래프에 그리기 위해 Double 배열로 변환
        // 필요하다면 여기서 날짜순 정렬 등을 수행
        let scores = recentScores.map { $0.score }
        return scores
    }
}
