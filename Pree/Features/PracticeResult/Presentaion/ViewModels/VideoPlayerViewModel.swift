//
//  VideoPlayerViewModel.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import Foundation
import AVKit
import Photos

import AVKit

@MainActor
final class VideoPlayerViewModel: ObservableObject {
    @Published var player: AVPlayer?
    
    func playVideo(from url: URL) {
        let item = AVPlayerItem(url: url)
        if player == nil {
            player = AVPlayer(playerItem: item)
        } else {
            player?.replaceCurrentItem(with: item)
        }
        
        // 오디오 설정
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        player?.play()
    }
    
    func cleanup() {
        player?.pause()
        player = nil
    }
}
