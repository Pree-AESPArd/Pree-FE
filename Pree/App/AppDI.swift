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

  // 2) UseCases
  let startCaptureUseCase: StartScreenCaptureUseCase
  let stopCaptureUseCase: StopScreenCaptureUseCase

  private init() {
    // Service 구현체 생성
    self.screenCaptureService = ScreenCaptureServiceImpl()

    // UseCase 에 주입
    self.startCaptureUseCase = StartScreenCaptureUseCase(service: screenCaptureService)
    self.stopCaptureUseCase  = StopScreenCaptureUseCase(service: screenCaptureService)
  }

  // 3) ViewModel 팩토리
  func makeCameraViewModel() -> CameraViewModel {
      CameraViewModel(
      start: startCaptureUseCase,
      stop:  stopCaptureUseCase
    )
  }
    
    func makeHomeViewModel() -> HomeViewModel {
        HomeViewModel()
    }
    
    func makePresnetationListViewModel() -> PresentaionListViewModel {
        PresentaionListViewModel()
    }
}
