//
//  APIServiceProtocol.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

protocol APIServiceProtocol {
    func fetchPresentations() async throws -> [PresentationDTO]
    func createPresentation(request: CreatePresentationRequestDTO) async throws -> PresentationDTO
    func uploadTake(presentationId: String, videoKey: String, eyeTrackingRate: Int, audioURL: URL) async throws -> TakeDTO
}
