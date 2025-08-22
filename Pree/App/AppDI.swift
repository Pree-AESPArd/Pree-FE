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
    
    // 2) UseCases
    let startCaptureUseCase: StartScreenCaptureUseCase
    let stopCaptureUseCase: StopScreenCaptureUseCase
    let eyeTrackingUseCase: EyeTrackingUseCase
    
    
    private init() {
        // Service 구현체 생성
        self.screenCaptureService = ScreenCaptureServiceImpl()
        self.eyeTrackingService = EyeTrackingServiceImpl()
        
        // UseCase 에 주입
        self.startCaptureUseCase = StartScreenCaptureUseCase(service: screenCaptureService)
        self.stopCaptureUseCase  = StopScreenCaptureUseCase(service: screenCaptureService)
        self.eyeTrackingUseCase = EyeTrackingUseCase(service: eyeTrackingService)
    }
    
    // 3) ViewModel 팩토리
    func makeCameraViewModel() -> CameraViewModel {
        CameraViewModel(
            start: startCaptureUseCase,
            stop:  stopCaptureUseCase,
            eyeTrackingUseCase: eyeTrackingUseCase
        )
    }
  
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel()
    }
    
    func makePresnetationListViewModel() -> PresentaionListViewModel {
        PresentaionListViewModel()
    }
    
    func makePracticeResultViewModel()-> PracticeResultViewModel {
        PracticeResultViewModel()
    }
    
    func makeAddNewPresentationModalViewModel() -> AddNewPresentationModalViewModel {
        AddNewPresentationModalViewModel()
    }
}
