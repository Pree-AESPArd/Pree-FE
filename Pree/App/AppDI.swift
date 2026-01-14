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
    private let startCaptureUseCase: StartScreenCaptureUseCaseProtocol
    private let stopCaptureUseCase: StopScreenCaptureUseCaseProtocol
    private let eyeTrackingUseCase: EyeTrackingUseCaseProtocol
    private let fetchPresentationUseCase: FetchPresentationsUseCaseProtocol
    private let createPresentationUseCase: CreatePresentationUseCase
    private let uploadPracticeUseCase: UploadPracticeUseCaseProtocol
    
    
    private init() {
        // Service 구현체 생성
        self.screenCaptureService = ScreenCaptureServiceImpl()
        self.eyeTrackingService = EyeTrackingServiceImpl()
        self.apiService = APIService()
        
        // Repository에 주입
        self.presentationRepository = PresentationRepository(apiService: apiService)
        
        // UseCase 에 주입
        self.startCaptureUseCase = StartScreenCaptureUseCase(service: screenCaptureService)
        self.stopCaptureUseCase  = StopScreenCaptureUseCase(service: screenCaptureService)
        self.eyeTrackingUseCase = EyeTrackingUseCase(service: eyeTrackingService)
        self.fetchPresentationUseCase = FetchPresentationsUseCase(presentationRepository: presentationRepository)
        self.createPresentationUseCase = CreatePresentationUseCase(repository: presentationRepository)
        self.uploadPracticeUseCase = UploadPracticeUseCase()
    }
    
    // 3) ViewModel 팩토리
    func makeCameraViewModel(newPresentation: Presentation) -> CameraViewModel {
        CameraViewModel(
            start: startCaptureUseCase,
            stop:  stopCaptureUseCase,
            eyeTrackingUseCase: eyeTrackingUseCase,
            presentation: newPresentation
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
        AddNewPresentationModalViewModel(createPresentationUsecase: createPresentationUseCase)
    }
    
    func makeCompleteViewModel(videoUrl: URL, eyeTrackingRate: Int) -> CompleteViewModel {
        CompleteViewModel(
            videoURL: videoUrl,
            eyeTrackingRate: eyeTrackingRate,
            uploadUseCase: uploadPracticeUseCase
        )
    }
    
}
