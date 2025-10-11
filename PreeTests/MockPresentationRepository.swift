//
//  MockPresentationRepository.swift
//  Pree
//
//  Created by KimDogyung on 10/11/25.
//

import Foundation
@testable import Pree // @testable을 사용해 internal 타입에 접근

final class MockPresentationRepository: PresentationRepository {
    
    // 테스트 목적에 따라 성공 또는 실패를 제어할 수 있는 속성
    var shouldThrowError = false
    var mockResponse: ResponseForNewPresentation?
    
    // createPresentation 메서드 호출 시, mock logic을 실행
    func createPresentation(createPresentationRequest: CreatePresentationRequest) async throws -> ResponseForNewPresentation {
        if shouldThrowError {
            // 테스트를 위해 미리 정의된 에러를 던집니다.
            throw URLError(.notConnectedToInternet)
        }
        
        // 성공 시 mockResponse를 반환하거나 기본 응답을 생성
        guard let response = mockResponse else {
            // 테스트를 위해 기본 mock 응답을 반환
            return ResponseForNewPresentation(
                presentationId: "test-id-123",
                presentationName: createPresentationRequest.presentationName,
                createdAt: "2025-10-11T00:00:00Z"
            )
        }
        return response
    }
    
    func fetchPresentations() async throws -> [Presentation] {
        // 이 테스트에서는 필요하지 않으므로, 기본 구현 또는 빈 배열 반환
        return []
    }
}
