//
//  MockAPIService.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation

// MARK: - 서버 시뮬레이션을 위한 Mock 객체
// 실제 통신 없이 미리 정해진 데이터를 반환
//struct MockAPIService: APIServiceProtocol {
//    func createPresentation(request: CreatePresentationRequestDTO) async throws -> PresentationDTO {
//        return PresentationDTO(presentationId: "d", presentationName: "d", idealMinTime: 2, idealMaxTime: 2, showTimeOnScreen: true, showMeOnScreen: true, isDevMode: true, totalScore: 90, totalPractices: 90, toggleFavorite: true, createdAt: "d", updatedAt: "d")
//    }
//    
//    func fetchPresentations() async throws -> [Presentation] {
//        // 실제 네트워크 지연을 시뮬레이션
//        try await Task.sleep(nanoseconds: 1_000_000_000) // 1초 대기
//        
//        // Mock 데이터 생성
//        let mockData = Presentation.mockList()
//        
//        return mockData
//    }
//    
//    func createPresentation(createPresentationRequest presentation: CreatePresentationRequest) async throws -> ResponseForNewPresentation {
//        return ResponseForNewPresentation(
////            presentationId: "25",
////            presentationName: "mock",
////            createdAt: "2025-11-16"
//        )
//    }
//}


//struct ResponseForNewPresentation {
//    
//}
