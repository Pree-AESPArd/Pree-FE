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
    @Published var timerString: String = "00:00"
    @Published var videoURL: URL?
    @Published var errorMessage: String?
    @Published var gazePoint: CGPoint = .zero // 시선이 닿은 화면 좌표 (UIKit 좌표계)
    
    
    private var recordingTimer: Timer?
    private var recordingTime: TimeInterval = 0
    
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
    
    func toggleCapture() {
        if isCapturing {
            stopRecordingTimer()
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
                    case .success:
                        self.isCapturing = true
                        self.startRecordingTimer()
                    case .failure(let err):
                        self.errorMessage = "\(err)"
                    }
                })
        }
    }
}
