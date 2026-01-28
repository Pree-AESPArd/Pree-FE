//
//  GetTakeResultUseCase.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

protocol GetTakeResultUseCaseProtocol {
    func execute(takeId: String) async throws -> TakeResult
}

final class GetTakeResultUseCase: GetTakeResultUseCaseProtocol {
    private let repository: TakeRepositoryProtocol
    
    init(repository: TakeRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(takeId: String) async throws -> TakeResult {
        let takeResult = try await repository.fetchTakeResult(takeId: takeId)
        
        return takeResult
    }
}
