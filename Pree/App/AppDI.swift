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
    private let mediaService: MediaServiceProtocol
    
    // Repository
    let presentationRepository: PresentationRepositoryProtocol //Reactive 패턴
    let takeRepository: TakeRepositoryProtocol
    
    // 2) UseCases
    private let startCaptureUseCase: StartScreenCaptureUseCaseProtocol
    private let stopCaptureUseCase: StopScreenCaptureUseCaseProtocol
    private let eyeTrackingUseCase: EyeTrackingUseCaseProtocol
    private let createPresentationUseCase: CreatePresentationUseCase
    private let uploadPracticeUseCase: UploadTakeUseCaseProtocol
    private let processMediaUseCase: ProcessMediaUseCaseProtocol
    private let getRecentScoresUseCase: GetRecentScoresUseCaseProtocol
    private let fetchTakesUseCase: FetchTakesUseCaseProtocol
    private let getTakeResultUseCase: GetTakeResultUseCaseProtocol
    private let getLatestProjectScoresUseCase: GetLatestProjectScoresUseCase
    private let searchProjectsUseCase: SearchProjectsUseCase
    
    private init() {
        // Service 구현체 생성
        self.screenCaptureService = ScreenCaptureServiceImpl()
        self.eyeTrackingService = EyeTrackingServiceImpl()
        self.apiService = APIService()
        self.mediaService = MediaServiceImpl()
        
        self.presentationRepository = PresentationRepository(apiService: self.apiService)
        self.takeRepository = TakeRepository(apiService: self.apiService)
        
        // UseCase 에 주입
        self.startCaptureUseCase = StartScreenCaptureUseCase(service: screenCaptureService)
        self.stopCaptureUseCase  = StopScreenCaptureUseCase(service: screenCaptureService)
        self.eyeTrackingUseCase = EyeTrackingUseCase(service: eyeTrackingService)
        self.createPresentationUseCase = CreatePresentationUseCase(repository: presentationRepository)
        self.uploadPracticeUseCase = UploadTakeUseCase(repository: takeRepository)
        self.processMediaUseCase = ProcessMediaUseCase(mediaService: mediaService)
        self.getRecentScoresUseCase = GetRecentScoresUseCase(repository: takeRepository)
        self.fetchTakesUseCase = FetchTakesUseCase(repository: takeRepository)
        self.getTakeResultUseCase = GetTakeResultUseCase(repository: takeRepository)
        self.getLatestProjectScoresUseCase = GetLatestProjectScoresUseCase(repository: presentationRepository)
        self.searchProjectsUseCase = SearchProjectsUseCase(repository: presentationRepository)
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
        return HomeViewModel(presentationRepository: presentationRepository,
                             getLatestProjectScoresUseCase: getLatestProjectScoresUseCase,
                             searchProjectsUseCase: searchProjectsUseCase
        )
    }
    
    func makePresnetationListViewModel(presentation: Presentation) -> PresentationListViewModel {
        return PresentationListViewModel(
            presentation: presentation,
            getRecentScoresUseCase: getRecentScoresUseCase,
            fetchTakesUseCase: fetchTakesUseCase
        )
    }
    
    func makePracticeResultViewModel(takeId: String) -> PracticeResultViewModel {
        return PracticeResultViewModel(
            takeId: takeId,
            getTakeResultUseCase: getTakeResultUseCase
        )
    }
    
    func makePresentationListModalViewModel() -> PresentationListModalViewModel {
        PresentationListModalViewModel(presentationRepository: presentationRepository)
    }
    
    func makeAddNewPresentationModalViewModel() -> AddNewPresentationModalViewModel {
        AddNewPresentationModalViewModel(createPresentationUsecase: createPresentationUseCase)
    }
    
    func makeCompleteViewModel(presentationId: String, videoUrl: URL, eyeTrackingRate: Int) -> CompleteViewModel {
        CompleteViewModel(
            presentatonId: presentationId,
            videoURL: videoUrl,
            eyeTrackingRate: eyeTrackingRate,
            processMediaUseCase: processMediaUseCase,
            uploadUseCase: uploadPracticeUseCase
        )
    }
    
}
