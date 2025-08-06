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
        
        
//        let plane = ModelEntity(
//            mesh: .generatePlane(width: 2, depth: 2), //    MeshResource.generatePlane(width:depth:) -> 2 m × 2 m 크기의 평면 메시(geometry)를 생성합니다.
//            materials: [UnlitMaterial(color: .init(.clear))]  // UnlitMaterial은 조명에 영향을 받지 않는 단색(material) 재질입니다. 투명색 적용
//        )
//        plane.generateCollisionShapes(recursive: false) // plane 모델(Entity)에 대해 “이게 ray-cast 가능한 geometry”를 생성해 줍니다. recursive: false이므로 자식 노드까지 내려가진 않고, 이 Entity 자체의 메시에 대해서만 충돌체를 만듭니다.
//        
//        //        let screenAnchor = AnchorEntity(world: [0,0,-1])
//        // 앵커(AnchorEntity)는 RealityKit에서 “가상 콘텐츠(Entity)를 어디에, 어떻게 고정시킬지”를 정해 주는 기준점
//        let screenAnchor = AnchorEntity(.camera) // RealityKit의 특별 앵커: “항상 카메라(디바이스) 좌표계에 고정”. 디바이스가 움직여도 앵커는 카메라 바로 뒤에서 따라붙습니다.
//        plane.setPosition([0, 0, -1], relativeTo: screenAnchor) // 앵커(local) 기준으로 Z축 음수 방향으로 1 m 떨어진 위치에 평면을 놓습니다.
//        screenAnchor.addChild(plane)    // 방금 만든 평면 Entity를 “카메라 앵커”의 자식 노드로 붙입니다.
//        arView.scene.addAnchor(screenAnchor) // 씬에 앵커 전체를 등록해야, 실제로 렌더링 혹은 레이캐스트 충돌 대상이 됩니다.
        
        // ─────────────── 보이지 않는 박스형 충돌체 설정 ───────────────
        let planeCollider = Entity()
        let cameraAnchor = AnchorEntity(.camera)
        planeCollider.setPosition([0, 0, -1], relativeTo: cameraAnchor)
        
        // ShapeResource.generateBox(width:height:depth:) 로 얇은 박스 생성
        let boxShape = ShapeResource.generateBox(
            width: 2.0,
            height: 2.0,
            depth: 0.001
        )
        planeCollider.components[CollisionComponent.self] =
        CollisionComponent(shapes: [boxShape], mode: .default)
        
        cameraAnchor.addChild(planeCollider)
        arView.scene.addAnchor(cameraAnchor)
        // ─────────────────────────────────────────────────────────────
        
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
                self?.computeGaze(from: faceAnchor, on: arView, using: planeCollider) ?? .zero
            }
        // sink: 파이프라인의 최종 구독자(subscriber) 역할.
        // 매 CGPoint를 받으면 subject.send(pt)로 내부 Subject에 흘려 넣습니다.
        // 이렇게 gazePublisher 를 구독하고 있는 모든 외부 구독자에게 pt가 전송됩니다.
            .sink { [weak self] pt in
                self?.subject.send(pt) // 최종 2D 좌표(pt)를 subject에 실어 발행
            }
    }
    
    
    public func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        // ① anchors 배열에서 ARFaceAnchor만 골라내고
        guard let anchor = anchors.compactMap({ $0 as? ARFaceAnchor }).first,
              let faceEntity = faceAnchorEntity else { return }
        
        // ② ARFaceAnchor가 알려준 눈의 4×4 변환 행렬(leftEyeTransform/rightEyeTransform)을
        //    우리가 만든 눈 Entity의 transform.matrix에 바로 덮어씌웁니다.
        // 눈 모델이 실제 눈의 위치와 자세를 실시간으로 따라가게 됨
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
          mesh: .generateCylinder(height: 0.05, radius: 0.01),
          materials: [mat]
        )
        eyeball.transform.rotation    = .init(angle: .pi/2, axis: [1,0,0])  // 기본적으로 y축 방향으로 위아래로 길게 세워진 원통을 x 축을 중심으로 라디안 90도 회전하면 z축 방향, 즉 눈이 보고 있는 방향으로 바뀜
        eyeball.transform.translation = [0,0,0.075] // 얼굴 기준 위치에서 7.5cm 앞으로” 살짝 띄워서 렌더링
        container.addChild(eyeball)
        
        // 3) 타겟 노드 (local z=1m)
        let target = Entity()  // 빈노드, 단지 부모인 container(눈 컨테이너)의 로컬 좌표계를 기준으로 위치를 갖습니다.
        target.transform.translation = [0,0,1] // target을 로컬 Z축 방향으로 1미터 이동시킵니다. 즉, container(눈 컨테이너)의 앞쪽 1미터 지점에 target이 “떠 있게” 됩니다.
        container.addChild(target) // 자식으로 붙임. 눈이 움직이거나 회전하면 target도 똑같이 따라감
        
        // 타켓 노드가 왜 필요한가
        // 시선(ray) 방향 계산
        // 눈의 원점(origin) 은 컨테이너의 월드 매트릭스 4열( columns.3 )이 말해주는 위치입니다.
        // target의 월드 좌표는 “눈 컨테이너가 바라보는’ 정면 방향”의 한 점을 가리키고 있죠.
        // (target 위치) − (origin 위치) 벡터를 정규화(normalize)하면, 눈이 보고 있는 정확한 방향 벡터를 얻을 수 있습니다.
        // 이 방향 벡터로 평면을 향해 raycast(광선 투사)를 하면, 화면 상의 시선 지점(2D 좌표)을 계산할 수 있어요.
        
        /*
        1.    점 A(origin) = (1,\,2,\,3)
        2.    점 B(target) = (4,\,6,\,3)

        이 두 점을 잇는 벡터를 구하려면
        overrightarrow{AB} = B - A = (4-1,\;6-2,\;3-3) = (3,\;4,\;0)
        •    이 벡터 (3,4,0)은 “얼마나 떨어져 있는지(크기)”와 “어느 방향으로 향하는지” 정보를 모두 갖고 있어요.
        •    하지만 Raycast에는 단지 방향만 필요하므로, 이 벡터를 단위 길이로 바꿉니다(정규화).

         \text{길이} = \sqrt{3^2 + 4^2 + 0^2} = 5
         \text{단위 벡터} = \frac{1}{5}(3,4,0) = (0.6,\;0.8,\;0.0)
         */
        
        
        return container
    }
    
    
//    private func computeGaze(
//        from faceAnchor: ARFaceAnchor,   // ① ARFaceAnchor: 매 프레임마다 업데이트되는 얼굴·눈 위치 정보
//        on arView: ARView,               // ② ARView: RealityKit 렌더링 뷰, 여기서 레이캐스트·프로젝션 수행
//        using plane: Entity         // ③ screen plane: 눈 시선이 부딪칠 가상의 투명 평면
//    ) -> CGPoint {
//        
//        // ───────────────────────────────────────────────────────────────
//        // screenHit(of:) : 하나의 눈(eye entity)에서 레이캐스트해
//        // 화면 평면과 충돌한 2D 스크린 좌표를 반환하는 내부 함수
//        func screenHit(of eye: Entity) -> CGPoint? {
//            // 1) eye 엔티티의 월드 변환 매트릭스 계산
//            let worldM = eye.transformMatrix(relativeTo: nil)
//            //    └─ eye.transformMatrix(relativeTo: nil)
//            //       - eye 로컬 좌표계를 월드 좌표계로 변환하는 4×4 행렬
//            
//            // 2) 매트릭스 네 번째 열(columns.3)에서 x,y,z 추출 → eye의 월드 위치(origin)
//            let origin = worldM.columns.3.xyz
//            //    └─ columns.3 : 행렬의 네 번째 열(translation 성분)
//            //    └─ .xyz : SIMD4→SIMD3 확장 프로퍼티
//            
//            // 3) eye 로컬 (0,0,1,1) 좌표를 월드로 변환 → 눈이 바라보는 “정면 지점”
//            let world4 = worldM * SIMD4<Float>(0, 0, 1, 1)
//            let target = SIMD3<Float>(world4.x, world4.y, world4.z)
//            //    └─ (0,0,1,1) : eye 컨테이너 로컬 앞쪽(z축 1m) 지점
//            //    └─ 곱셈 결과 → world4 : 그 지점의 월드 좌표
//            
//            // 4) 방향 벡터(direction) 계산: normalize(target – origin)
//            let dir = normalize(target - origin)
//            //    └─ (target – origin) : 눈 위치→앞쪽 지점으로 향하는 벡터
//            //    └─ normalize()    : 단위 길이 벡터로 변환
//            
//            // 5) 레이캐스트(ray) 쏘기
//            let hits = arView.scene.raycast(
//                origin: origin,
//                direction: dir,
//                length: 3.0,        // 최대 3m까지
//                query: .nearest     // 가장 가까운 충돌만
//            )
//            //    └─ origin : 눈의 월드 위치
//            //    └─ direction : 눈이 바라보는 단위 방향 벡터
//            
//            // 6) 충돌 결과 중 우리가 만든 plane과 충돌한 첫 지점 찾기
//            if let hit = hits.first(where: { $0.entity == plane }) {
//                // 7) 3D 충돌 지점(hit.position)을 2D 화면 좌표로 투영
//                return arView.project(hit.position)
//            }
//            
//            // 8) 평면과 충돌하지 않으면 nil 반환
//            return nil
//        }
//        // ───────────────────────────────────────────────────────────────
//        
//        // 9) 왼쪽·오른쪽 눈에 대해 각각 screenHit 실행
//        guard let pL = screenHit(of: leftEyeEntity),
//              let pR = screenHit(of: rightEyeEntity)
//        else {
//            // 10) 어느 한 쪽이라도 실패하면 (시선 미검출) CGPoint.zero 반환
//            return .zero
//        }
//        
//        // 11) 둘의 x,y 좌표를 평균 내서 최종 시선 위치 계산
//        let x = (pL.x + pR.x) * 0.5
//        let y = (pL.y + pR.y) * 0.5
//        //    └─ RealityKit 좌표계는 화면 좌하단(origin)이기 때문에
//        //       별도의 y 반전 처리 없이 그대로 사용
//        
//        // 12) CGPoint 로 포장해 반환
//        return CGPoint(x: x, y: y)
//    }
//
    
    private func computeGaze(
        from faceAnchor: ARFaceAnchor,
        on arView: ARView,
        using plane: Entity
    ) -> CGPoint {
        func screenHit(of eye: Entity) -> CGPoint? {
            let worldM = eye.transformMatrix(relativeTo: nil)
            let origin = worldM.columns.3.xyz
            let world4 = worldM * SIMD4<Float>(0, 0, -1, 1)
            let target = SIMD3<Float>(world4.x, world4.y, world4.z)
            let dir = normalize(target - origin)

            //--- 디버그 로그 ---
            print("origin:", origin, "dir:", dir)

            let hits = arView.scene.raycast(
                origin: origin,
                direction: dir,
                length: 3.0,
                query: .nearest
            )
            if let hit = hits.first(where: { $0.entity == plane }) {
                let p = arView.project(hit.position)!
                //--- 디버그 로그 ---
                print("→ Plane hit at", hit.position, "projected to", p)
                return p
            }
            return nil
        }

        guard let pL = screenHit(of: leftEyeEntity),
              let pR = screenHit(of: rightEyeEntity) else {
            return .zero
        }

        // 원래 계산된 화면 좌표
        let rawX = (pL.x + pR.x) * 0.5
        let rawY = (pL.y + pR.y) * 0.5

        // 화면 크기를 읽어서 좌표 뒤집기
        let size = arView.bounds.size
        let flippedX = size.width  - rawX
        let flippedY = size.height - rawY

        let gazePoint = CGPoint(x: flippedX, y: flippedY)
        print("Computed gazePoint (flipped) =", gazePoint)
        return gazePoint
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
