//
//  ProcessMediaUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//

import Foundation

protocol ProcessMediaUseCaseProtocol {
    func execute(videoURL: URL) async throws -> (videoKey: String, audioURL: URL)
}
