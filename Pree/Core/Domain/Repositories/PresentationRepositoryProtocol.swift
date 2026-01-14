//
//  PresentaionRepository.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

protocol PresentationRepositoryProtocol {
    func fetchPresentations() async throws -> [Presentation]
    
    func createNewPresentation(request: CreatePresentationRequest) async throws -> Presentation
}

