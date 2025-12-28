//
//  CreatePresentationUseCase.swift
//  Pree
//
//  Created by KimDogyung on 11/22/25.
//

import Foundation

protocol CreatePresentationUseCaseProtocol {
    
    func execute(presentation: CreatePresentationRequest) async throws -> ResponseForNewPresentation
}
