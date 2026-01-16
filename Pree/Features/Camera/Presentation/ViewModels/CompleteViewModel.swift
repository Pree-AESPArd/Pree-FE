//
//  CompleteViewModel.swift
//  Pree
//
//  Created by KimDogyung on 11/11/25.
//

import SwiftUI
import AVFoundation
import Photos

final class CompleteViewModel: ObservableObject {
    
    private let presentationId: String
    private let videoURL: URL // 녹화된 원본 임시 파일
    private let eyeTrackingRate: Int
    private let processMediaUseCase: ProcessMediaUseCaseProtocol
    private let uploadUseCase: UploadTakeUseCaseProtocol
    
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var isUploadComplete: Bool = false
    
    private var videoKey: String = "";
    
    init(
        presentatonId: String,
        videoURL: URL,
        eyeTrackingRate: Int,
        processMediaUseCase: ProcessMediaUseCaseProtocol,
        uploadUseCase: UploadTakeUseCaseProtocol
    ) {
        self.presentationId = presentatonId
        self.videoURL = videoURL
        self.eyeTrackingRate = eyeTrackingRate
        self.processMediaUseCase = processMediaUseCase
        self.uploadUseCase = uploadUseCase
    }
    
    
    func processVideo() {
        isLoading = true
        
        Task {
            do {
                
                
                // 미디어 가공
                let (videoKey, audioFileUrl) = try await processMediaUseCase.execute(videoURL: self.videoURL)
                
                print("✅ 처리 완료 - Key: \(videoKey), Audio: \(audioFileUrl)")
                
                try await uploadUseCase.execute(
                    presentationId: presentationId,
                    videoKey: videoKey,
                    audioURL: audioFileUrl,
                    eyeTrackingRate: eyeTrackingRate
                )
                
                // 알림창 UI 테스트용 코드
                // try await Task.sleep(nanoseconds: 1_500_000_000)
                // throw NSError(domain: "TestError", code: 999, userInfo: [NSLocalizedDescriptionKey: "테스트용 강제 에러가 발생했습니다! 💥"])
                
                // 뒷정리 (임시 파일 삭제)
                cleanupTemporaryFiles(audioURL: audioFileUrl)
                
                // 완료 상태 업데이트 -> UI 이동
                await MainActor.run {
                    self.isLoading = false
                    self.isUploadComplete = true
                }
                
            } catch {
                print("❌ 처리 중 오류 발생: \(error)")
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }
    
    
    private func cleanupTemporaryFiles(audioURL: URL) {
        try? FileManager.default.removeItem(at: videoURL) // 원본 임시 영상 삭제
        try? FileManager.default.removeItem(at: audioURL) // 추출한 오디오 삭제
    }
    
}
