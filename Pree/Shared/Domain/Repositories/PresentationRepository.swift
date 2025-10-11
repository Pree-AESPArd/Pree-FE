//
//  PresentaionRepository.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

protocol PresentationRepository {
    func fetchPresentations() async throws -> [Presentation]
    
    func createPresentation(createPresentationRequest: CreatePresentationRequest) async throws -> ResponseForNewPresentation
}
