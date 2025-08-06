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

extension SIMD4 where Scalar == Float {
  var xyz: SIMD3<Float> { SIMD3<Float>(x, y, z) }
}

public final class EyeTrackingServiceImpl: NSObject, EyeTrackingService, ARSessionDelegate{
    
    // 1) Combine 퍼블리셔 역할: 시선 좌표를 내보낼 Subject
    private let subject = PassthroughSubject<CGPoint, Never>()
    
    // 2) 외부에 공개할 퍼블리셔: 읽기 전용 AnyPublisher
    /**
     gazePublisher는
     읽기 전용 퍼블리셔 인터페이스(AnyPublisher)만 외부에 주고,
     내부의 PassthroughSubject 구현 세부를 숨깁니다.
     **/
    public var gazePublisher: AnyPublisher<CGPoint, Never> {
        subject.eraseToAnyPublisher()
        // 구현 은닉
        // 외부에서 gazePublisher를 구독(subscribe)만 할 수 있고,
        // send나 completion 호출 같은 Subject 고유 API는 보이지 않게 합니다.
        // 덕분에 “발행 역할”은 이 서비스 내부로 캡슐화(encapsulation)됩니다.
    }
    
    /*
     1.    PassthroughSubject<CGPoint, Never> = 라디오 스튜디오의 송출 장비
     •    당신(서비스)이 “시선 좌표”라는 신호를 직접 만들어서 (subject.send(pt)) 송출할 수 있어요.
     •    송출 장비에는 볼륨 조절, 신호 생성 같은 내부 조작용 버튼들이 잔뜩 달려 있죠.
     2.    AnyPublisher<CGPoint, Never> = 일반 청취용 라디오 채널
     •    청취자(앱의 다른 부분)는 단지 “채널 98.7FM”을 틀어서 방송을 듣기만 하면 됩니다.
     •    송출 장비 뒤에서 어떤 버튼을 어떻게 누르는지는 몰라도,
     •    “시선 좌표 신호”가 올 때마다 편안히 들을 수만 있으면 돼요.
     3.    eraseToAnyPublisher() = 스튜디오 내부 장비를 가려 주는 스크린
     •    방송국 밖에서는 내부의 송출 버튼·다이얼 같은 복잡한 장치를 전혀 볼 수 없도록 스크린을 쳐 놓는 것과 같아요.
     •    덕분에 청취자(구독자)는 “채널만 알면” 안전하게 방송을 들을 수 있고,
     •    방송국 내부 구조를 바꾸더라도(송출 장비를 바꿔도) 채널 번호(AnyPublisher)는 그대로 유지됩니다.
     */
    
    
    private var cancellable: AnyCancellable?
    private var arView: ARView?
    
    private var faceAnchorEntity: AnchorEntity?
    private var leftEyeEntity: Entity!
    private var rightEyeEntity: Entity!
    
    
    public override init() { super.init() }
    
    
    public func startTracking(in arView: ARView) throws {
        // ① keep a reference to the real ARView
        self.arView = arView
        
        // 1) 이 기기에서 Face Tracking이 지원되는지 확인
        // TrueDepth 센서가 없는 기기 (iPhone 8) 이하는 걸러져야 함
        guard ARFaceTrackingConfiguration.isSupported else {
            throw TrackingError.notSupported
        }
        
        
        // ② optionally disable RealityKit auto-configuration
        arView.automaticallyConfigureSession = false
        
        arView.session.delegate = self
        
        // ③ run the face-tracking session
        let config = ARFaceTrackingConfiguration() // ARFaceTrackingConfiguration 생성
        config.isLightEstimationEnabled = true  // 조명 정보도 받고 싶다면
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors]) // 세션 실행 (전면 카메라로)
        
        
        let plane = ModelEntity(
            mesh: .generatePlane(width: 2, depth: 2),
            materials: [UnlitMaterial(color: .init(.clear))]
        )
        plane.generateCollisionShapes(recursive: false)
        //        let screenAnchor = AnchorEntity(world: [0,0,-1])
        let screenAnchor = AnchorEntity(.camera)
        plane.setPosition([0, 0, -1], relativeTo: screenAnchor)
        
        screenAnchor.addChild(plane)
        arView.scene.addAnchor(screenAnchor)
        
        // 눈 모델(Entity) 준비
        leftEyeEntity  = makeEyeContainer(color: .red.withAlphaComponent(0.4))
        rightEyeEntity = makeEyeContainer(color: .blue.withAlphaComponent(0.4))
        let faceEntity = AnchorEntity(.face)
        faceEntity.addChild(leftEyeEntity)
        faceEntity.addChild(rightEyeEntity)
        arView.scene.addAnchor(faceEntity)
        faceAnchorEntity = faceEntity
        
        // ④ tear down any old subscription
        cancellable?.cancel()
        
        // ⑤ subscribe to per-frame updates
        // Combine 파이프라인: 매 프레임마다 얼굴 앵커 추출 → 시선점 계산 → subject로 발행
        // RealityKit의 씬(Scene) 에 매 프레임 렌더링 직전에 발생하는 SceneEvents.Update 이벤트를 내보내고 매 프레임마다 호출
        cancellable = arView.scene
            .publisher(for: SceneEvents.Update.self)
        // compactMap은 “클로저가 nil을 반환한 요소는 걸러내고, ARFaceAnchor로 성공적으로 캐스팅된 요소만을 모아 새 배열 만듬
            .compactMap { [weak self] _ in
                self?.arView?.session.currentFrame?
                    .anchors
                    .compactMap { $0 as? ARFaceAnchor } // anchors 배열의 각 요소($0)를 ARFaceAnchor로 타입 캐스팅(as? ARFaceAnchor)을 시도
                    .first
            }
            .map { [weak self] faceAnchor in
                //                                let worldPoint = faceAnchor.lookAtPoint // ARFaceAnchor.lookAtPoint: 사용자 눈의 시선이 향하는 3D 월드 좌표
                //                                // project returns optional CGPoint, so fallback
                //                                let screenPos = self?.arView?.project(worldPoint) ?? .zero
                //                                return screenPos
                //                self?.trackEyes(from: faceAnchor) ?? .zero
                self?.computeGaze(from: faceAnchor, on: arView, using: plane) ?? .zero
            }
        // sink: 파이프라인의 최종 구독자(subscriber) 역할.
        // 매 CGPoint를 받으면 subject.send(pt)로 내부 Subject에 흘려 넣습니다.
        // 이렇게 gazePublisher 를 구독하고 있는 모든 외부 구독자에게 pt가 전송됩니다.
            .sink { [weak self] pt in
                self?.subject.send(pt) // 최종 2D 좌표(pt)를 subject에 실어 발행
            }
    }
    
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        guard let anchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first,
              let faceEntity = faceAnchorEntity else { return }
        
        // 눈 Entity에 faceAnchorTransforms 반영
        leftEyeEntity.transform.matrix  = anchor.leftEyeTransform
        rightEyeEntity.transform.matrix = anchor.rightEyeTransform
    }
    
    
    private func makeEyeContainer(color: UIColor) -> Entity {
        // 1) 빈 컨테이너
        let container = Entity()
        
        // 2) 눈 기하 + 머리 방향 offset(앞으로 0.075m)
        var mat = UnlitMaterial()
        mat.color = .init(tint: color)
        let eyeball = ModelEntity(
          mesh: .generateCylinder(height: 0.15, radius: 0.01),
          materials: [mat]
        )
        eyeball.transform.rotation    = .init(angle: .pi/2, axis: [1,0,0])
        eyeball.transform.translation = [0,0,0.075]
        container.addChild(eyeball)
        
        // 3) 타겟 노드 (local z=1m)
        let target = Entity()
        target.transform.translation = [0,0,1]
        container.addChild(target)
        
        return container
    }
    
    
    private func computeGaze(
        from faceAnchor: ARFaceAnchor,
        on arView: ARView,
        using plane: ModelEntity
    ) -> CGPoint {
        
        func screenHit(of eye: Entity) -> CGPoint? {
          // 1) 월드 매트릭스
          let worldM = eye.transformMatrix(relativeTo: nil)
          let origin = worldM.columns.3.xyz
          
          // 2) 로컬(0,0,1,1)을 월드로 변환
          let world4 = worldM * SIMD4<Float>(0,0,1,1)
          let target = SIMD3<Float>(world4.x, world4.y, world4.z)
          
          let dir = normalize(target - origin)
          let hits = arView.scene.raycast(
            origin: origin,
            direction: dir,
            length: 3.0,
            query: .nearest
          )
          if let hit = hits.first(where: { $0.entity == plane }) {
            return arView.project(hit.position)
          }
          return nil
        }
        
        guard let pL = screenHit(of: leftEyeEntity),
              let pR = screenHit(of: rightEyeEntity)
        else { return .zero }
        
        // RealityKit origin 은 bottom-left 이므로 Y는 그대로
        let x = (pL.x + pR.x) * 0.5
        let y = (pL.y + pR.y) * 0.5
        return CGPoint(x: x, y: y)
    }
    
    
    
    
    //    private func setupVirtualPlane(in arView: ARView) {
    //        // 기존 평면 제거
    //        if let existingAnchor = planeAnchor {
    //            arView.scene.removeAnchor(existingAnchor)
    //        }
    //
    //        // 더 큰 평면 생성 (2m x 2m)
    //        let mesh = MeshResource.generatePlane(width: 2.0, depth: 2.0)
    //        var material = UnlitMaterial()
    //        material.color = .init(tint: .clear) // 투명하게
    //
    //        planeEntity = ModelEntity(mesh: mesh, materials: [material])
    //
    //        // 충돌 감지를 위한 설정 개선
    //        planeEntity?.generateCollisionShapes(recursive: false)
    //
    //        // 평면을 더 멀리 배치 (1m 앞)
    //        planeAnchor = AnchorEntity(.camera)
    //        planeEntity.setPosition([0, 0, -1], relativeTo: planeAnchor)
    //
    //        if let planeEntity = planeEntity, let planeAnchor = planeAnchor {
    //            planeAnchor.addChild(planeEntity)
    //            arView.scene.addAnchor(planeAnchor)
    //        }
    //
    //        print("Virtual plane setup complete")
    //    }
    //
    
    
    
    private func calculateBasicGazePoint(from faceAnchor: ARFaceAnchor) -> CGPoint {
        guard let arView = self.arView else { return .zero }
        
        let worldPoint = faceAnchor.lookAtPoint
        guard let screenPos = arView.project(worldPoint) else { return .zero }
        
        // 좌표 정규화 - 올바른 방향으로 매핑
        return CGPoint(
            x: screenPos.x, // X축 반전 제거 - 자연스러운 매핑
            y: screenPos.y
        )
    }
    
    
    
    
    public func stopTracking() {
        cancellable?.cancel()
        self.arView?.session.pause()
    }
    
    
    
    public enum TrackingError: Error {
        case notSupported
    }
}
