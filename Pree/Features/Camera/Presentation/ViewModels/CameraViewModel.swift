//
//  CameraViewModel.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI
import ReplayKit

@MainActor
final class CameraViewModel: ObservableObject {
    @Published var isCapturing = false
    @Published var videoURL: URL?
    @Published var errorMessage: String?
    @Published var gazePoint: CGPoint? = nil // 시선이 닿은 화면 좌표 (UIKit 좌표계)
    
    private let startUseCase: StartScreenCaptureUseCase
    private let stopUseCase: StopScreenCaptureUseCase
    
    public init(
        start: StartScreenCaptureUseCase,
        stop:  StopScreenCaptureUseCase
    ) {
        self.startUseCase = start
        self.stopUseCase  = stop
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
