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
    
    // viewmodel을 RootTabView가 아니라 View에서 만드는 이유:
    // 생명주기를 SwiftUI가 직접 관리하면서 화면이 떠 있는 동안 한번만 ViewModel이 생성되게 하기 위해서
    // navigationDestination의 클로저는 화면 상태가 변경되어 다시 그려질때 재실행 가능성 높음
    init(presentation: CreatePresentationRequest?) {
        _vm = StateObject(wrappedValue: AppDI.shared.makeCameraViewModel(newPresentation: presentation))
    }
    
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
        .task {
            // 새롭게 발표를 생성할시 서버에 전송
            // 새로운 발표가 아니라 기존 발표에서 새 영상 찍는거면 아무것도 안함
            await vm.createPresentaionIfNotNull()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            vm.stopTracking()
        }
        .alert("오류 발생", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("확인") {
                // 경고창이 닫힐 때 필요한 추가 로직 (예: 뒤로가기)
                // 현재는 경고창이 사라지면 에러 메시지를 nil로 만듭니다.
                navigationManager.path.removeLast()
            }
        } message: {
            // 경고창에 표시될 메시지
            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
            }
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





//#Preview {
//    let vm = AppDI.shared.makeCameraViewModel()
//    CameraView(vm: vm)
//        .environmentObject(NavigationManager())
//}
