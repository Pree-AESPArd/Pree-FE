//
//  AppDI.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import Foundation
import ReplayKit

@MainActor
final class AppDI {
    
    // 싱글톤 형태로 전역에서 접근
    static let shared = AppDI()
    
    // 1) Service
    private let screenCaptureService: ScreenCaptureService
    private let eyeTrackingService: EyeTrackingService
    private let apiService: APIServiceProtocol
    
    // Repository
    private let presentationRepository: PresentationRepository
    
    // 2) UseCases
    let startCaptureUseCase: StartScreenCaptureUseCase
    let stopCaptureUseCase: StopScreenCaptureUseCase
    let eyeTrackingUseCase: EyeTrackingUseCase
    private let fetchPresentationUseCase: FetchPresentationsUseCase
    private let createPresentationUseCase: CreatePresentationUseCase
    
    
    private init() {
        // Service 구현체 생성
        self.screenCaptureService = ScreenCaptureServiceImpl()
        self.eyeTrackingService = EyeTrackingServiceImpl()
        self.apiService = MockAPIService() // test 용 mock 주입
        
        // Repository에 주입
        self.presentationRepository = PresentationRepositoryImpl(apiService: apiService)
        
        // UseCase 에 주입
        self.startCaptureUseCase = StartScreenCaptureUseCase(service: screenCaptureService)
        self.stopCaptureUseCase  = StopScreenCaptureUseCase(service: screenCaptureService)
        self.eyeTrackingUseCase = EyeTrackingUseCase(service: eyeTrackingService)
        self.fetchPresentationUseCase = FetchPresentationsUseCase(presentationRepository: presentationRepository)
        self.createPresentationUseCase = CreatePresentationUseCase(presentationRepository: presentationRepository)
    }
    
    // 3) ViewModel 팩토리
    func makeCameraViewModel() -> CameraViewModel {
        CameraViewModel(
            start: startCaptureUseCase,
            stop:  stopCaptureUseCase,
            eyeTrackingUseCase: eyeTrackingUseCase,
            createPresentationUseCase: createPresentationUseCase
        )
    }
  
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel(fetchPresentationsUseCase: fetchPresentationUseCase)
    }
    
    func makePresnetationListViewModel() -> PresentaionListViewModel {
        PresentaionListViewModel()
    }
    
    func makePracticeResultViewModel()-> PracticeResultViewModel {
        PracticeResultViewModel()
    }
    
    func makePresentationListModalViewModel() -> PresentationListModalViewModel {
        PresentationListModalViewModel()
    }
    
    func makeAddNewPresentationModalViewModel() -> AddNewPresentationModalViewModel {
        AddNewPresentationModalViewModel()
    }
    
}
