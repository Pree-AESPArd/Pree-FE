//
//  EyeTrackingService.swift
//  Pree
//
//  Created by KimDogyung on 8/2/25.
//

import ARKit
import RealityKit
import Combine
import CoreGraphics

public final class EyeTrackingServiceImpl: NSObject, EyeTrackingService, ARSessionDelegate {
    
    private let subject = PassthroughSubject<CGPoint, Never>()
    public var gazePublisher: AnyPublisher<CGPoint, Never> { subject.eraseToAnyPublisher() }
    
    private var arView: ARView?
    private var physicalScreenSize: CGSize = .zero // 물리적 크기 저장용
    
    public override init() { super.init() }
    
    public func startTracking(in arView: ARView) throws {
        self.arView = arView
        
        // 1. ⭐️ 기기의 물리적 크기를 미리 가져옵니다.
        self.physicalScreenSize = DeviceDimensionHelper.getPhysicalSize()
        
        // Debug
        //print("Device size: \(self.physicalScreenSize)")
        
        guard ARFaceTrackingConfiguration.isSupported else { throw TrackingError.notSupported }
        
        arView.automaticallyConfigureSession = false
        arView.session.delegate = self
        
        // 렌더링 설정
        arView.contentScaleFactor = 1.0
        arView.renderOptions = [.disableMotionBlur, .disableDepthOfField, .disableFaceMesh]
        
        let config = ARFaceTrackingConfiguration()
        config.isLightEstimationEnabled = false
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // ARKit이 얼굴을 감지하면 호출되는 함수
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // 얼굴 앵커 가져오기
        guard let faceAnchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first else { return }
        
        // 시선 계산 실행
        let gazePoint = computeGazeWithPhysicalRatio(faceAnchor: faceAnchor)
        
        // 발행
        subject.send(gazePoint)
    }
    
    // [핵심 로직] 물리 크기 비례식을 이용한 계산
    // 3D 공간의 눈 위치를 기기 크기와 비교해서 화면 좌표로 바꿈
    private func computeGazeWithPhysicalRatio(faceAnchor: ARFaceAnchor) -> CGPoint {
        guard let arView = arView else { return .zero }
        
        // 1. 눈의 월드 변환 행렬
        let faceTransform = faceAnchor.transform
        let leftEyeWorld = faceTransform * faceAnchor.leftEyeTransform
        let rightEyeWorld = faceTransform * faceAnchor.rightEyeTransform
        
        // 2. 시선 벡터 계산 (눈 앞 50cm 지점)
        // (Z값이 시선 방향이라고 가정, ARKit은 보통 +Z가 사용자 쪽)
        let distance: Float = 0.5
        let leftTarget = leftEyeWorld * SIMD4<Float>(0, 0, distance, 1)
        let rightTarget = rightEyeWorld * SIMD4<Float>(0, 0, distance, 1)
        
        // 3. 두 눈의 평균 3D 좌표 (미터 단위)
        // x: 카메라 중심 기준 좌우 (오른쪽이 +)
        // y: 카메라 중심 기준 상하 (위쪽이 +)
        let xMeter = (leftTarget.x + rightTarget.x) / 2
        let yMeter = (leftTarget.y + rightTarget.y) / 2
        
        // 4. 물리적 비율 계산 (Ratio)
        // 공식: (현재 미터 위치) / (전체 물리 가로 길이 / 2)
        // 0이면 화면 중앙, 1이면 화면 끝
        let xRatio = CGFloat(xMeter) / (physicalScreenSize.width / 2.0)
        let yRatio = CGFloat(yMeter) / (physicalScreenSize.height / 2.0)
        
        // 5. 픽셀 좌표로 변환
        // 화면 중앙 좌표
        let screenWidth = arView.bounds.width
        let screenHeight = arView.bounds.height
        let centerX = screenWidth / 2.0
        let centerY = screenHeight / 2.0
        
        // 최종 좌표 계산
        // x: 중앙 + (비율 * 중앙까지의 거리)
        // y: 중앙 - (비율 * 중앙까지의 거리) -> Y축은 위로 갈수록 좌표가 작아지므로 빼줌(또는 더함, 방향 확인 필요)
        // 전면 카메라는 좌우 반전이 있을 수 있으므로 x는 상황에 따라 +/- 조정
        let screenX = centerX + (xRatio * centerX * 2.5) // * 2.5는 민감도(Sensitivity) 증폭값
        let screenY = centerY - (yRatio * centerY * 2.5)
        
        return CGPoint(x: screenX, y: screenY)
    }
    
    public func stopTracking() {
        arView?.session.pause()
    }
    
    public enum TrackingError: Error {
        case notSupported
    }
}
