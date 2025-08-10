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
    
//    private let service: EyeTrackingService
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
