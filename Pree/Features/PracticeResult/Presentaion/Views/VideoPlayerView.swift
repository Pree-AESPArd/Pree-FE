//
//  VideoPlayerView.swift
//  Pree
//
//  Created by 이유현 on 8/2/25.
//

import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let videoKey: String // PHAsset identifier
    @StateObject private var viewModel = VideoPlayerViewModel()
    
    var body: some View {
        ZStack {
            if let player = viewModel.player {
                VideoPlayerRepresentable(player: player)
                    .frame(height: 225)
                    .cornerRadius(20)
            } else {
                // 로딩 중일 때 Progress 표시
                VStack(spacing: 0) {
                    Spacer()
                    
                    HStack{
                        Spacer()
                        
                        ProgressView()
                            .tint(Color.primary)
                            
                        Spacer()
                    
                    } // :HStack
                    
                    Spacer()
                } // :VStack
                .frame(height: 225)
                .background(.black)
                .cornerRadius(20)
            }
        }
        .onAppear {
            // View 등장 시 영상 로딩
            viewModel.loadVideo(from: videoKey)
        }
        .onDisappear {
            // View 사라질 때 영상 멈춤
            viewModel.player?.pause()
        }
    }
}

// MARK: - UIViewControllerRepresentable
struct VideoPlayerRepresentable: UIViewControllerRepresentable {
    let player: AVPlayer
    
    // AVPlayerViewController 생성
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true                      // 재생/일시정지 등 기본 컨트롤 보이기
        controller.videoGravity = .resizeAspectFill                  // 영상 비율 조정 (화면 가득 채우기)
        controller.allowsPictureInPicturePlayback = true            // PIP 모드 허용
        controller.canStartPictureInPictureAutomaticallyFromInline = true
        return controller
    }
    
    // 플레이어가 바뀌었을 경우 업데이트
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player !== player {
            uiViewController.player = player
        }
    }
}
