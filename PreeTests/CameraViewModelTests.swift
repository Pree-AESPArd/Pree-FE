//
//  CameraViewModelTests.swift
//  Pree
//
//  Created by KimDogyung on 10/11/25.
//

import XCTest
import Combine
@testable import Pree

@MainActor // ViewModel이 @MainActor이므로 테스트도 MainActor에서 실행
final class CameraViewModelTests: XCTestCase {
    
    var mockRepository: MockPresentationRepository!
    var createPresentationUseCase: CreatePresentationUseCase!
    var cameraViewModel: CameraViewModel!
    var cancellables = Set<AnyCancellable>()
    
    // 각 테스트 메서드가 실행되기 전에 호출
    override func setUp() {
        super.setUp()
        // Mock 객체 및 테스트할 객체들을 초기화
        mockRepository = MockPresentationRepository()
        createPresentationUseCase = CreatePresentationUseCase(presentationRepository: mockRepository)
        
        // ViewModel에 UseCase 주입
        cameraViewModel = CameraViewModel(
            start: MockStartScreenCaptureUseCase(), // 다른 의존성도 Mock으로 주입
            stop: MockStopScreenCaptureUseCase(),
            eyeTrackingUseCase: MockEyeTrackingUseCase(),
            createPresentationUseCase: createPresentationUseCase
        )
    }
    
    // 각 테스트 메서드가 끝난 후에 호출
    override func tearDown() {
        mockRepository = nil
        createPresentationUseCase = nil
        cameraViewModel = nil
        cancellables.removeAll()
        super.tearDown()
    }

    // 성공적인 API 호출 시 ViewModel 상태 변화를 테스트
    func test_createPresentation_success() async throws {
        // Given: 성공 시나리오 설정
        mockRepository.shouldThrowError = false
        let request = CreatePresentationRequest(
            presentationName: "Test Presentation",
            idealMinTime: 10,
            idealMaxTime: 20,
            showTimeOnScreen: true,
            showMeOnScreen: false
        )
        
        // When: 비동기 함수 실행
        await cameraViewModel.createPresentaion(newPresentation: request)
        
        // Then: ViewModel의 상태가 예상대로 변경되었는지 확인
        // 성공 시 errorMessage가 nil인지 확인
        XCTAssertNil(cameraViewModel.errorMessage)
    }
    
    // API 호출 실패 시 ViewModel 상태 변화를 테스트
    func test_createPresentation_failure() async {
        // Given: 실패 시나리오 설정
        mockRepository.shouldThrowError = true
        let request = CreatePresentationRequest(
            presentationName: "Test Presentation",
            idealMinTime: 10,
            idealMaxTime: 20,
            showTimeOnScreen: true,
            showMeOnScreen: false
        )
        
        let expectation = XCTestExpectation(description: "Wait for errorMessage to be set")
        
        // When: 비동기 함수 실행 및 ViewModel 상태 변화 감지
        cameraViewModel.$errorMessage
            .dropFirst() // 초기값 무시
            .sink { errorMessage in
                // Then: errorMessage가 예상대로 설정되었는지 확인
                XCTAssertNotNil(errorMessage)
                XCTAssertEqual(errorMessage, URLError(.notConnectedToInternet).localizedDescription)
                expectation.fulfill()
            }
            .store(in: &cancellables)
        
        await cameraViewModel.createPresentaion(newPresentation: request)
        
        // 비동기 작업이 완료되기를 기다립니다.
        await fulfillment(of: [expectation], timeout: 1.0)
    }
}
