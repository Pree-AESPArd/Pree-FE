//
//  AppDI.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import Foundation
import ReplayKit


final class AppDI {
  
  // 싱글톤 형태로 전역에서 접근
  static let shared = AppDI()

  // 1) Service
  private let screenRecorderService: ScreenRecordingService

  // 2) UseCases
  let startRecordingUseCase: StartScreenRecordingUseCase
  let stopRecordingUseCase: StopScreenRecordingUseCase

  private init() {
    // Service 구현체 생성
    self.screenRecorderService = ReplayKitScreenRecorder()

    // UseCase 에 주입
    self.startRecordingUseCase = StartScreenRecordingUseCase(service: screenRecorderService)
    self.stopRecordingUseCase  = StopScreenRecordingUseCase(service: screenRecorderService)
  }

  // 3) ViewModel 팩토리
  func makeCameraViewModel() -> CameraViewModel {
      CameraViewModel(
      start: startRecordingUseCase,
      stop:  stopRecordingUseCase
    )
  }
}
