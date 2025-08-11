//
//  CameraViewModel.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI
import ReplayKit
import Combine
import RealityKit

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var isCapturing = false
    @Published var isCalibrating = false
    @Published var videoURL: URL?
    @Published var errorMessage: String?
    @Published var gazePoint: CGPoint = .zero // 시선이 닿은 화면 좌표 (UIKit 좌표계)
    
    private let startUseCase: StartScreenCaptureUseCase
    private let stopUseCase: StopScreenCaptureUseCase
    
    private let eyeTrackingUseCase: EyeTrackingUseCase
    
    private var cancellables = Set<AnyCancellable>()
//    private let calibrationProcessor = CalibrationProcessor()
 
    
    let arView: ARView
    
    public init(
        start: StartScreenCaptureUseCase,
        stop:  StopScreenCaptureUseCase,
        eyeTrackingUseCase: EyeTrackingUseCase
    ) {
        self.startUseCase = start
        self.stopUseCase  = stop
        self.eyeTrackingUseCase = eyeTrackingUseCase
        self.arView = ARView(frame: .zero)
        self.eyeTrackingUseCase.gazePublisher
                    .receive(on: DispatchQueue.main)            // UI 업데이트는 메인 스레드
                    .assign(to: \.gazePoint, on: self)
                    .store(in: &cancellables)
    }
    
    
    func startCalibration() {
        if !isCalibrating {
            isCalibrating = true
            
        }
    }
    
    
    func stopTracking(){
//        self.service.stopTracking()
        self.eyeTrackingUseCase.stop()
        
    }
    
    func resumeTracking() {
        do {
            try eyeTrackingUseCase.start(in: arView)
        } catch {
            print("Could not restart face tracking:", error)
        }
    }
    
//    func processAndStoreCalibration(targets: [CGPoint], samples: [[CGPoint]]) {
//        // calibrationProcessor.calculate의 결과는 GazeCalibration 또는 PiecewiseCalibration 이지만,
//        // 두 타입 모두 GazeMapper 역할을 채택했으므로 문제없이 전달 가능합니다.
//        let result = calibrationProcessor.calculate(targets: targets, samples: samples)
//        
//        switch result {
//        case .success(let hybridCalibrationModel):
//            print("✅ Calibration successful!")
//            // UseCase에 특정 모델이 아닌, GazeMapper '역할'을 전달
//            self.eyeTrackingUseCase.setCalibration(mapper: hybridCalibrationModel) // <--- 여기를 수정
//        case .failure(let error):
//            print("❌ Calibration failed: \(error)")
//            self.errorMessage = "Calibration failed. Please try again."
//        }
//    }
    
    func processAndStoreCalibration(targets: [CGPoint], samples: [[CGPoint]]) {
        // 직접 OffsetCalibration 모델을 생성합니다.
        if let offsetModel = OffsetCalibration(targets: targets, samples: samples) {
            print("✅ Offset Calibration successful!")
            
            // UseCase는 GazeMapper 역할만 알기 때문에, OffsetCalibration 모델도 전달 가능합니다.
            self.eyeTrackingUseCase.setCalibration(mapper: offsetModel)
            
        } else {
            print("❌ Offset Calibration failed.")
            self.errorMessage = "Calibration failed. Please try again."
        }
    }
    
    
    func toggleCapture() {
        if isCapturing {
            stopUseCase.execute { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        self.videoURL = url
                    case .failure(let err):
                        self.errorMessage = "\(err)"
                    }
                    self.isCapturing = false
                }
            }
        } else {
            startUseCase.execute(
                completion: { result in
                    switch result {
                    case .success: self.isCapturing = true
                    case .failure(let err): self.errorMessage = "\(err)"
                    }
                })
        }
    }
}
