//
//  CameraView.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI
import RealityKit
import ARKit
import AVKit

struct CameraView: View {
    @StateObject var vm: CameraViewModel
    @StateObject private var overlayManager = OverlayWindowManager()
    
    @State private var player: AVPlayer?
    
    var body: some View {
        
        Group {
            FrontCameraPreview()
                .edgesIgnoringSafeArea(.all)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            overlayManager.show {
                OverlayView()
            }
        }
        
    }
}


struct FrontCameraPreview: UIViewRepresentable {
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // 1) 이 기기에서 Face Tracking이 지원되는지 확인
        // TrueDepth 센서가 없는 기기 (iPhone 8) 이하는 걸러져야 함
        guard ARFaceTrackingConfiguration.isSupported else {
            // 지원 안 하면 그냥 빈 ARView 돌려줌
            // TODO: 뒤로가기 구현
            return arView
        }
        
        // 2) ARFaceTrackingConfiguration 생성
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = true  // 조명 정보도 받고 싶다면
        
        // 3) 세션 실행 (전면 카메라로)
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
        
        // (선택) 자동 세션 구성 끄기, 디버그 옵션 끄기
        arView.automaticallyConfigureSession = false
        arView.debugOptions = []
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        // 화면 회전 등 업데이트 필요 시 처리
    }
}




#Preview {
    let vm = AppDI.shared.makeCameraViewModel()
    CameraView(vm: vm)
        .environmentObject(NavigationManager())
}
