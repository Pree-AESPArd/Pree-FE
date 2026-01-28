//
//  VideoResourceService.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

import Photos
import UIKit

enum VideoError: Error {
    case unauthorized
    case notFound
    case conversionFailed
}

final class VideoResourceService {
    static let shared = VideoResourceService()
    private init() {}
    
    /// 로컬 식별자(videoKey)를 이용해 갤러리에서 영상 URL을 가져옴
    func fetchVideoURL(from localIdentifier: String) async throws -> URL {
        // 1. 권한 확인
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        guard status == .authorized || status == .limited else {
            throw VideoError.unauthorized
        }
        
        // 2. Asset 찾기
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
        guard let asset = assets.firstObject else {
            // 갤러리에 영상이 없다는 것을 감지
            throw VideoError.notFound
        }
        
        // 3. AVAsset -> URL 변환 (Async)
        return try await withCheckedThrowingContinuation { continuation in
            let options = PHVideoRequestOptions()
            options.deliveryMode = .highQualityFormat
            options.isNetworkAccessAllowed = true // 아이클라우드 동기화된 영상도 허용
            
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, info in
                if let urlAsset = avAsset as? AVURLAsset {
                    continuation.resume(returning: urlAsset.url)
                } else {
                    continuation.resume(throwing: VideoError.conversionFailed)
                }
            }
        }
    }
}
