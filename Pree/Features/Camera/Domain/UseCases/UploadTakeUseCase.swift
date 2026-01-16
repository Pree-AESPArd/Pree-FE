//
//  UploadPracticeUseCase.swift
//  Pree
//
//  Created by KimDogyung on 11/22/25.
//

import Foundation

struct UploadTakeUseCase: UploadTakeUseCaseProtocol {
    let repository: TakeRepositoryProtocol
    
    func execute(presentationId: String, videoKey: String, audioURL: URL, eyeTrackingRate: Int) async throws {
        try await repository.uploadPractice(
            presentationId: presentationId,
            videoKey: videoKey,
            eyeTrackingRate: eyeTrackingRate,
            audioURL: audioURL
        )
    }
}
