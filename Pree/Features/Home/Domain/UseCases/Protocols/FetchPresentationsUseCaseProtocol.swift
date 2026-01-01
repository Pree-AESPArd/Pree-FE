//
//  FetchPresentationsUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 11/22/25.
//

import Foundation

protocol FetchPresentationsUseCaseProtocol {
    
    func execute() async throws -> [Presentation]
}
