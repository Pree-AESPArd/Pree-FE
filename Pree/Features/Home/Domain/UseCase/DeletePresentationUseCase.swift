//
//  DeletePresentationUseCase.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

protocol DeletePresentationUseCaseProtocol {
    func execute(id: String) async throws
}

final class DeletePresentationUseCase: DeletePresentationUseCaseProtocol {
    private let repository: PresentationRepositoryProtocol
    
    init(repository: PresentationRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(id: String) async throws {
        try await repository.deletePresentation(id: id)
    }
}
