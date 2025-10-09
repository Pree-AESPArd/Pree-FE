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
    @Published var isDoneCalibration: Bool = false
    @Published var isDebugMode: Bool = true
    @Published var timerString: String = "00:00"
    @Published var eyeTrackingTimerString: String = "00:00"
    @Published var videoURL: URL?
    @Published var errorMessage: String?
    @Published var gazePoint: CGPoint = .zero // 시선이 닿은 화면 좌표 (UIKit 좌표계)
    
    
    private var recordingTimer: Timer?
    private var recordingTime: TimeInterval = 0
    
    // 시선 추적 타이머 관련 프로퍼티
    private var eyeTrackingTimer: Timer?
    private var eyeTrackingTime: TimeInterval = 0
    private var lookAwayTimer: Timer? // 0.5초간 시선이 밖에 있는지 확인하는 타이머
    private let screenBounds = UIScreen.main.bounds // 화면 경계
    private let edgeThreshold: CGFloat = 20 // 가장 자리 얼마 만큼 공간을 타이머가 멈추는 공간으로 설정할건지
    
    private let startUseCase: StartScreenCaptureUseCase
    private let stopUseCase: StopScreenCaptureUseCase
    
    private let eyeTrackingUseCase: EyeTrackingUseCase
    
    private var cancellables = Set<AnyCancellable>()
    
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
        
        // gazePoint 변경을 감지하여 타이머 로직 실행
        $gazePoint
            .dropFirst() // 초기값(.zero)은 무시
            .sink { [weak self] point in
                self?.handleGazeUpdate(point: point)
            }
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
    
    
    func processAndStoreCalibration(targets: [CGPoint], samples: [[CGPoint]]) {
        // 직접 OffsetCalibration 모델을 생성합니다.
        if let offsetModel = CalibrationServiceImpl(targets: targets, samples: samples) {
            print("✅ Offset Calibration successful!")
            
            self.eyeTrackingUseCase.setCalibration(calibrationService: offsetModel)
            
            self.eyeTrackingUseCase.setFinalAdjustment(x: 15.0, y: -5.0) 
            
        } else {
            print("❌ Offset Calibration failed.")
            self.errorMessage = "Calibration failed. Please try again."
        }
    }
    
    
    private func startRecordingTimer() {
        recordingTimer?.invalidate()
        
        recordingTime = 0
        timerString = "00:00"
        
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in

            DispatchQueue.main.async {
                guard let self = self else { return }
                
                self.recordingTime += 1
                let minutes = Int(self.recordingTime) / 60
                let seconds = Int(self.recordingTime) % 60
                self.timerString = String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }

    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    
    /// gazePoint가 업데이트될 때마다 호출되어 타이머 상태를 관리합니다.
    private func handleGazeUpdate(point: CGPoint) {
        // 촬영 중일 때만 동작
        guard isCapturing else { return }
        
        // 화면 경계를 벗어났는지 확인
        let isLookingAway = point.x < edgeThreshold || point.x > screenBounds.width - edgeThreshold || point.y < edgeThreshold || point.y > screenBounds.height - edgeThreshold
        
        if isLookingAway {
            // 시선이 밖에 있을 때, 0.5초 후에 타이머를 멈추는 타이머를 시작 (이미 시작되지 않았다면)
            if lookAwayTimer == nil {
                lookAwayTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { [weak self] _ in
                    // Ensure this call happens on the main thread ---
                    DispatchQueue.main.async {
                        self?.pauseEyeTrackingTimer()
                    }
                }
            }
        } else {
            // 시선이 안에 있으면, lookAwayTimer를 즉시 중단하고 시선 추적 타이머를 재개
            lookAwayTimer?.invalidate()
            lookAwayTimer = nil
            resumeEyeTrackingTimer()
        }
    }
    
    /// 시선 추적 타이머를 시작 (또는 재개)합니다.
    private func resumeEyeTrackingTimer() {
        // 이미 실행 중이면 아무것도 하지 않음
        guard eyeTrackingTimer == nil else { return }
        
        eyeTrackingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.eyeTrackingTime += 0.1
                let minutes = Int(self.eyeTrackingTime) / 60
                let seconds = Int(self.eyeTrackingTime) % 60
                self.eyeTrackingTimerString = String(format: "%02d:%02d", minutes, seconds)
            }
        }
    }
    
    /// 시선 추적 타이머를 일시 정지합니다.
    private func pauseEyeTrackingTimer() {
        eyeTrackingTimer?.invalidate()
        eyeTrackingTimer = nil
    }
    
    /// 모든 시선 추적 타이머를 완전히 중지하고 초기화합니다.
    private func stopAndResetEyeTrackingTimer() {
        pauseEyeTrackingTimer()
        lookAwayTimer?.invalidate()
        lookAwayTimer = nil
        eyeTrackingTime = 0
        eyeTrackingTimerString = "00:00"
    }
    
    func toggleCapture() {
        if isCapturing {
            self.isCapturing = false
            
            stopRecordingTimer()
            stopAndResetEyeTrackingTimer()
            stopUseCase.execute { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        self.videoURL = url
                    case .failure(let err):
                        self.errorMessage = "\(err)"
                    }
                }
            }
        } else {
            
            startUseCase.execute(
                completion: { result in
                    switch result {
                    case .success:
                        self.isCapturing = true
                        self.startRecordingTimer()
                        self.resumeEyeTrackingTimer()
                    case .failure(let err):
                        self.errorMessage = "\(err)"
                    }
                })
        }
    }
    
    
    func createPresentaion(newPresentation: CreatePresentationRequest) {
        
    }
    
}
