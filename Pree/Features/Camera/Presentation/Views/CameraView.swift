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
    @StateObject private var overlayManager = OverlayWindowManager()
    
    
    var body: some View {
        
        ZStack {
            //            FrontCameraPreview(gazePoint: $vm.gazePoint)
            //                .edgesIgnoringSafeArea(.all)
            FrontCameraPreview(arView: vm.arView)
                .ignoresSafeArea()
            
            Circle()
                .fill(.red.opacity(0.8))
                .frame(width: 12, height: 12)
                .position(vm.gazePoint)
            
            
            //            if let pt = vm.gazePoint {
            //                Circle()
            //                    .fill(Color.red.opacity(0.8))
            //                    .frame(width: 12, height: 12)
            //                    .position(pt) // UIKit 좌표계 기준
            //            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            overlayManager.show {
                OverlayView(vm: vm)
            }
            vm.startCalibration()
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






//struct FrontCameraPreview: UIViewRepresentable {
//    @Binding var gazePoint: CGPoint?
//
//    func makeUIView(context: Context) -> ARView {
//        let arView = ARView(frame: .zero)
//
//        // 1) 이 기기에서 Face Tracking이 지원되는지 확인
//        // TrueDepth 센서가 없는 기기 (iPhone 8) 이하는 걸러져야 함
//        guard ARFaceTrackingConfiguration.isSupported else {
//            // 지원 안 하면 그냥 빈 ARView 돌려줌
//            // TODO: 뒤로가기 구현
//            return arView
//        }
//
//        // 2) ARFaceTrackingConfiguration 생성
//        let config = ARFaceTrackingConfiguration()
//        config.isLightEstimationEnabled = true  // 조명 정보도 받고 싶다면
//
//        // 3) 세션 실행 (전면 카메라로)
//        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
//
//        // (선택) 자동 세션 구성 끄기, 디버그 옵션 끄기
//        arView.automaticallyConfigureSession = false
//        arView.debugOptions = []
//
//
//        // 4) 매 프레임마다 얼굴 앵커 업데이트 콜백
//        // RealityKit의 씬(Scene) 에 매 프레임 렌더링 직전에 발생하는 SceneEvents.Update 이벤트를 구독(subscribe)하고 매 프레임마다 호출. Combine 사용함
//        arView.scene.subscribe(to: SceneEvents.Update.self) { event in
//            guard
//                let faceAnchor = arView.session.currentFrame?
//                    .anchors // ARAnchor 배열. ARFrame에는 그 프레임에서 트래킹된 모든 ARAnchor 객체의 배열이 들어 있음 ([ARAnchor]).
//                    .compactMap({ $0 as? ARFaceAnchor }) // anchors 배열의 각 요소($0)를 ARFaceAnchor로 타입 캐스팅(as? ARFaceAnchor)을 시도
//                        // compactMap은 “클로저가 nil을 반환한 요소는 걸러내고, ARFaceAnchor로 성공적으로 캐스팅된 요소만을 모아 새 배열 만듬
//                    .first // 첫번째 원소
//            else {
//                return
//            }
//
//            // 5) ARFaceAnchor.lookAtPoint: 사용자 눈의 시선이 향하는 3D 월드 좌표
//            let lookAt = faceAnchor.lookAtPoint
//
//            // 6) 화면 좌표로 투영
//            let screenPos = arView.project(lookAt) //RealityKit의 ARView.project(_:) 메서드는 3D 월드 좌표를 2D 화면 좌표(CGPoint)로 변환해 줍니다.
//
//
//            // 7) main thread에서 Publish. UI 변경은 항상 메인 스레드
//            DispatchQueue.main.async {
//                gazePoint = CGPoint(x: screenPos?.x ?? 0, y: screenPos?.y ?? 0)
//                print(gazePoint)
//            }
//        }.store(in: &context.coordinator.cancellables) //cancellable을 Set<AnyCancellable>에 넣어 두라는 뜻
//
//        /*
//         이렇게 보관해 두면, 뷰(또는 코디네이터)가 살아 있는 동안 구독도 유지되고
//         뷰/코디네이터가 메모리에서 해제(deinit)될 때 일괄적으로 모든 구독이 자동으로 취소(cancellable.cancel())됩니다.
//         context.coordinator.cancellables: makeUIView(context:)에서 구독할 때마다 이 집합에 저장해 두어, 뷰가 사라질 때 코디네이터가 해제되면서 자연스럽게 모든 구독이 정리됩니다.
//        */
//
//        return arView
//    }
//
//    func updateUIView(_ uiView: ARView, context: Context) {
//        // 화면 회전 등 업데이트 필요 시 처리
//    }
//    func makeCoordinator() -> Coordinator { Coordinator() }
//
//    class Coordinator {
//        var cancellables = Set<AnyCancellable>()
//    }
//}




#Preview {
    let vm = AppDI.shared.makeCameraViewModel()
    CameraView(vm: vm)
}
