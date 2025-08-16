//
//  CameraView.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI
import RealityKit
import ARKit
import Combine

struct CameraView: View {
    @StateObject var vm: CameraViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var overlayManager = OverlayWindowManager()
    
    
    var body: some View {
        
        ZStack {
            
            FrontCameraPreview(arView: vm.arView)
                .ignoresSafeArea()
            
            Circle()
                .fill(.red.opacity(0.8))
                .frame(width: 12, height: 12)
                .position(vm.gazePoint)
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true // 화면 자동꺼짐 방지
            overlayManager.show {
                OverlayView(vm: vm, overlayManager: overlayManager)
                    .environmentObject(navigationManager)
            }
            vm.resumeTracking()
        }
        .onChange(of: vm.videoURL) {
            if let url = vm.videoURL {
                
            }
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            vm.stopTracking()
        }
        
    }
}

struct FrontCameraPreview: UIViewRepresentable {
    let arView: ARView
    
    
    func makeUIView(context: Context) -> ARView {
        // The service already ran session.run(...) and is publishing gaze.
        // You could even share that ARView instance if you like.
        
        return arView
    }
    func updateUIView(_ uiView: ARView, context: Context) {}
}





#Preview {
    let vm = AppDI.shared.makeCameraViewModel()
    CameraView(vm: vm)
        .environmentObject(NavigationManager())
}
