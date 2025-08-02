//
//  VideoPlayerViewModel.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import Foundation
import AVKit
import Photos

final class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    
    // 비디오 식별자(PHAsset local identifier)를 받아 해당 영상을 로드
    func loadVideo(from identifier: String) {
        // 사용자에게 사진 라이브러리 접근 권한 요청
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                print("사진 접근 권한이 없습니다.")
                return
            }

            // identifier로 PHAsset 찾기
            let results = PHAsset.fetchAssets(withLocalIdentifiers: [identifier], options: nil)
            guard let asset = results.firstObject else {
                print("PHAsset을 찾을 수 없습니다.")
                return
            }

            let options = PHVideoRequestOptions()
            options.deliveryMode = .highQualityFormat // 고화질 요청

            // AVAsset (실제 비디오 파일)을 비동기로 요청
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { avAsset, _, _ in
                if let urlAsset = avAsset as? AVURLAsset {
                    // AVPlayer를 메인 스레드에서 초기화
                    DispatchQueue.main.async {
                        self.setupPlayer(with: urlAsset.url)
                    }
                } else {
                    print("AVAsset을 가져올 수 없습니다.")
                }
            }
        }
    }

    // AVPlayer 구성 및 자동 재생
    private func setupPlayer(with url: URL) {
        let item = AVPlayerItem(url: url)
        let player = AVPlayer(playerItem: item)
        self.player = player
        
        // 오디오 세션 설정 (음소거 모드에서도 재생 가능하도록)
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("오디오 세션 설정 실패: \(error)")
        }

        player.play()
    }
}

