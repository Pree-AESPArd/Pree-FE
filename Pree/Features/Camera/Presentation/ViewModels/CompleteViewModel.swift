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
    let videoURL: URL
    let eyeTrackingRate: Int
//    var isNewPresentationPractice: Bool
//    let practiceMode: PracticeMode
    let uploadUseCase: UploadPracticeUseCaseProtocol
    
    init(
        videoURL: URL,
        eyeTrackingRate: Int,
//        practiceMode: PracticeMode,
        uploadUseCase: UploadPracticeUseCaseProtocol
    ) {
        self.videoURL = videoURL
        self.eyeTrackingRate = eyeTrackingRate
//        self.isNewPresentationPractice = isNewPresentationPractice
//        self.practiceMode = practiceMode
        self.uploadUseCase = uploadUseCase
    }
    
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil
    @Published var isSaveComplete: Bool = false
    @Published var isUploadComplete: Bool = false
    
    
    private var videoKey: String = "";
    
    // TODO: AppDI를 통해 주입받도록 수정
    // private let uploadAudioUseCase: UploadAudioUseCaseProtocol
    
    
    // TODO: 데이터를 어떤 순서로 어떻게 보낼건지 서버랑 합의해야함
    func processVideo() {
        isLoading = true
        
        Task {
            do {
                // 1. 갤러리에 비디오 저장 (동시에 진행)
                async let saveResult: String = saveVideoToGallery()
                
                // 2. 오디오 추출 및 업로드 (동시에 진행)
                async let uploadResult: Void = extractAndUploadAudio()
                
                // 두 작업이 모두 끝날 때까지 기다림
                let (savedVideoID, _) = try await (saveResult, uploadResult)
                
                videoKey = savedVideoID
                // TODO: 새 발표의 영상인지 기존 발표의 영상인지에 따라 보내는게 달라짐
//                try await uploadPracticeUseCase.execute(
//                    mode: practiceMode,
//                    videoKey: videoKey,
//                    eyeTrackingRate: eyeTrackingRate,
//                    audioURL: audioURL
//                )
                
                // 모든 작업 완료
//                try? FileManager.default.removeItem(at: audioURL)
                self.isLoading = false
                self.isSaveComplete = true
                self.isUploadComplete = true // 리포트 화면 이동 트리거
                
            } catch {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    
    private func saveVideoToGallery() async throws -> String {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized else {
            throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey : "저장 권한이 필요합니다."])
        }
        
        var placeholder: PHObjectPlaceholder?
        
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL)
            
            placeholder = request?.placeholderForCreatedAsset
        }
        
        guard let localIdentifier = placeholder?.localIdentifier else {
            throw NSError(domain: "PhotoLibraryError", code: 10, userInfo: [NSLocalizedDescriptionKey: "비디오 저장 후 ID를 가져오는데 실패했습니다."])
        }
        
        return localIdentifier
    }
    
    // TODO: 함수 이름 바꾸기, 오디오만 보내는게 아니니
    private func extractAndUploadAudio() async throws {
        // 1. 오디오 추출
        let audioURL = try await extractAudioFromVideo()
        
        // 2. 오디오 업로드 (UseCase 사용)
        try await uploadAudio(url: audioURL)
        
        // 3. 임시 오디오 파일 삭제 (선택 사항)
        try? FileManager.default.removeItem(at: audioURL)
    }
    
    
    private func extractAudioFromVideo() async throws -> URL {
        let asset = AVURLAsset(url: videoURL)
        
        // 오디오 추출 세션 생성
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(domain: "AVError", code: 2, userInfo: [NSLocalizedDescriptionKey: "오디오 추출 세션을 만들 수 없습니다."])
        }
        
        
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
        

        exportSession.outputFileType = .m4a
        
        // ✅ iOS 18 이상: 새 API 사용
        if #available(iOS 18.0, *) {
            try await exportSession.export(to: outputURL, as: .m4a)
            return outputURL
        } else {
            // ✅ iOS 17 이하: 기존 방식 유지
            exportSession.outputURL = outputURL
            
            await withCheckedContinuation { continuation in
                exportSession.exportAsynchronously {
                    continuation.resume()
                }
            }
            
            if exportSession.status == .completed {
                return outputURL
            } else {
                throw exportSession.error ?? NSError(domain: "AVError", code: 3, userInfo: [NSLocalizedDescriptionKey: "오디오 추출 실패"])
            }
        }
        
    }
    
    /// 추출된 오디오 파일을 서버로 업로드합니다.
    private func uploadAudio(url: URL) async throws {
        // TODO: 여기서 실제 UseCase를 호출하여 서버로 업로드합니다.
        // TODO: practice도 같이 업로드
        // 예: try await uploadAudioUseCase.execute(fileURL: url)
        
        // --- 데모용 임시 코드 ---
        // 실제 네트워크 통신을 시뮬레이션하기 위해 2초 대기
        print("오디오 업로드 시작: \(url)")
        try await Task.sleep(nanoseconds: 2_000_000_000) // 2초
        print("오디오 업로드 성공")
        // --- 데모용 임시 코드 끝 ---
    }
    
    private func createPracticeModel() -> CreatePracticeAfterCreatePresentation {
        return CreatePracticeAfterCreatePresentation.init(
            userId: "userId",
            videoKey: videoKey,
            eyePercentage: eyeTrackingRate,
        )
    }
    
}
