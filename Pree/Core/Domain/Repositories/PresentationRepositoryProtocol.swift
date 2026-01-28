//
//  PresentaionRepository.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

protocol PresentationRepositoryProtocol {
    func fetchPresentations(sortOption: String) async throws
    
    func createNewPresentation(request: CreatePresentationRequest) async throws -> Presentation
    
    func toggleFavorite(projectId: String) async throws
    
    func fetchLatestProjectScores() async throws -> ProjectAverageScores
    
    func searchProjects(query: String) async throws -> [Presentation]
    
    func deletePresentation(id: String) async throws
}

