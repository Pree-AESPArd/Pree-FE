//
//  APIServiceProtocol.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

protocol APIServiceProtocol {
    func fetchPresentations() async throws -> [Presentation]
    func createPresentation(request: CreatePresentationRequestDTO) async throws -> PresentationDTO
}
