//
//  CameraView.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI
import AVKit

struct CameraView: View {
    @StateObject var vm: CameraViewModel
    @StateObject private var overlayManager = OverlayWindowManager()
    
    @State private var player: AVPlayer?
    
    var body: some View {
        
        VStack(spacing: 20) {
            if vm.isCapturing {
                Text("🔴 Capturing...")
            } else {
                Text("⏺️ Ready")
            }
            
            
            
            
            Button(action: vm.toggleCapture) {
                Text(vm.isCapturing ? "Stop Capture" : "Start Capture")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(vm.isCapturing ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            
            if let url = vm.videoURL {
                VideoPlayer(player: player)
                    .frame(height: 300)
                    .onAppear {
                        player = AVPlayer(url: url)
                        player?.play()  // 자동 재생
                    }
                    .onDisappear {
                        player?.pause()
                        player = nil
                    }
            }
            if let err = vm.errorMessage {
                Text(err).foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            overlayManager.show {
                OverlayView()
            }
        }
        
    }
}






#Preview {
    let vm = AppDI.shared.makeCameraViewModel()
    CameraView(vm: vm)
}
