//
//  TakeRepository.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//

import Foundation

final class TakeRepository: TakeRepositoryProtocol {
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func uploadPractice(presentationId: String, videoKey: String, eyeTrackingRate: Int, audioURL: URL) async throws {
        // APIService를 호출하여 업로드 수행
        // 결과값(DTO)이 필요하다면 반환하고, 아니면 에러가 안 나는지만 확인
        let _ = try await apiService.uploadTake(
            presentationId: presentationId,
            videoKey: videoKey,
            eyeTrackingRate: eyeTrackingRate,
            audioURL: audioURL
        )
    }
}
