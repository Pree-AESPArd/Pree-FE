//
//  ProcessMediaUseCase.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//

import Foundation

final class ProcessMediaUseCase: ProcessMediaUseCaseProtocol {
    private let mediaService: MediaServiceProtocol
    
    init(mediaService: MediaServiceProtocol) {
        self.mediaService = mediaService
    }
    
    func execute(videoURL: URL) async throws -> (videoKey: String, audioURL: URL) {
        // 병렬 처리 수행 
        async let keyTask = mediaService.saveVideoToGallery(url: videoURL)
        async let audioTask = mediaService.extractAudio(from: videoURL)
        
        return try await (keyTask, audioTask)
    }
}
