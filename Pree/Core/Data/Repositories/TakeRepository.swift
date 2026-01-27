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
    
    func fetchRecentScores(presentationId: String) async throws -> [RecentScore] {
        return try await apiService.fetchFiveTakesScores(presentationId: presentationId)
    }
    
    
    func fetchTakes(presentationId: String) async throws -> [Take] {
        // 1. API 호출하여 DTO 배열 받기
        let dtos = try await apiService.fetchTakes(presentationId: presentationId)
        
        // 2. DTO -> Domain Entity 변환
        return dtos.map { $0.toDomain() }
            .sorted { $0.takeNumber > $1.takeNumber } // 회차 역순 정렬
    }
}
