//
//  MediaServiceImpl.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//

import AVFoundation
import Photos

final class MediaServiceImpl: MediaServiceProtocol {
    
    func saveVideoToGallery(url: URL) async throws -> String {
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        
        guard status == .authorized else {
            throw NSError(domain: "Pree", code: 403, userInfo: [NSLocalizedDescriptionKey: "갤러리 접근 권한이 없습니다."])
        }
        
        var placeholder: PHObjectPlaceholder?
        
        try await PHPhotoLibrary.shared().performChanges {
            let request = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            
            placeholder = request?.placeholderForCreatedAsset
        }
        
        guard let localIdentifier = placeholder?.localIdentifier else {
            throw NSError(domain: "Pree", code: 500, userInfo: [NSLocalizedDescriptionKey: "Video ID 획득 실패"])
        }
        
        return localIdentifier
    }
    
    func extractAudio(from videoURL: URL) async throws -> URL {
        let asset = AVURLAsset(url: videoURL)
        
        // 프리셋 설정 (m4a - 오디오만 추출)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetAppleM4A) else {
            throw NSError(domain: "Pree", code: 500, userInfo: [NSLocalizedDescriptionKey: "Export Session 생성 실패"])
        }
        
        // 임시 저장 경로 생성
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")
        
        // 기존 파일 있으면 삭제
        try? FileManager.default.removeItem(at: outputURL)
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .m4a
        
        // iOS 18 이상: 새 API 사용
        if #available(iOS 18.0, *) {
            try await exportSession.export(to: outputURL, as: .m4a)
            return outputURL
        } else {
            // iOS 17 이하: 기존 방식 유지
            await exportSession.export()
            
            if exportSession.status == .completed {
                return outputURL
            } else {
                throw exportSession.error ?? NSError(domain: "Pree", code: 500, userInfo: [NSLocalizedDescriptionKey: "오디오 추출 실패"])
            }
        }
    }
}
