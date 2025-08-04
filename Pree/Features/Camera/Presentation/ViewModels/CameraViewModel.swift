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
    
    private let service: EyeTrackingService
    private var cancellables = Set<AnyCancellable>()
    
    let arView: ARView
    
    public init(
        start: StartScreenCaptureUseCase,
        stop:  StopScreenCaptureUseCase,
        service: EyeTrackingService
    ) {
        self.startUseCase = start
        self.stopUseCase  = stop
        self.arView = ARView(frame: .zero)
        self.service = service
        try? service.startTracking(in: arView)
            service.gazePublisher
              .receive(on: DispatchQueue.main)
              .assign(to: \.gazePoint, on: self)
              .store(in: &cancellables)
    }
    
   
    
    
    func startCalibration() {
        if !isCalibrating {
            isCalibrating = true
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
//                self.isCalibrating = false
//            }
        }
    }
    
    
    func getCurrentLookingPoint(isCalibrating: Bool) {
        var currentGazePoint: [CGPoint] = []
        
        while isCalibrating {
            currentGazePoint.append(gazePoint)
        }
        
        print(currentGazePoint)
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
