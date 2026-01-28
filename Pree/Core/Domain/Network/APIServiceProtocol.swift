//
//  APIServiceProtocol.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

protocol APIServiceProtocol {
    func fetchPresentations(sortOption: String) async throws -> [PresentationDTO]
    func createPresentation(request: CreatePresentationRequestDTO) async throws -> PresentationDTO
    func uploadTake(presentationId: String, videoKey: String, eyeTrackingRate: Int, audioURL: URL) async throws -> TakeDTO
    func toggleFavorite(projectId: String) async throws -> Bool
    func fetchFiveTakesScores(presentationId: String) async throws -> [RecentScore]
    func fetchTakes(presentationId: String) async throws -> [TakeDTO]
    func fetchTakeResult(takeId: String) async throws -> TakeResultDTO
    func fetchLatestAverageScores() async throws -> ProjectAverageScoresDTO
    func searchProjects(query: String) async throws -> [PresentationDTO]
    func deleteProject(projectId: String) async throws
}
