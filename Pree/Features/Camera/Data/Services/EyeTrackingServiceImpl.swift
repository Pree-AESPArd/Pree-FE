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

public final class EyeTrackingServiceImpl: EyeTrackingService {
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

    public init() {}

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

        // ③ run the face-tracking session
        let config = ARFaceTrackingConfiguration() // ARFaceTrackingConfiguration 생성
        config.isLightEstimationEnabled = true  // 조명 정보도 받고 싶다면
        arView.session.run(config, options: [.resetTracking, .removeExistingAnchors]) // 세션 실행 (전면 카메라로)

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
                let worldPoint = faceAnchor.lookAtPoint // ARFaceAnchor.lookAtPoint: 사용자 눈의 시선이 향하는 3D 월드 좌표
                // project returns optional CGPoint, so fallback
                return self?.arView?.project(worldPoint) ?? .zero
            }
            // sink: 파이프라인의 최종 구독자(subscriber) 역할.
            // 매 CGPoint를 받으면 subject.send(pt)로 내부 Subject에 흘려 넣습니다.
            // 이렇게 gazePublisher 를 구독하고 있는 모든 외부 구독자에게 pt가 전송됩니다.
            .sink { [weak self] pt in
                self?.subject.send(pt) // 최종 2D 좌표(pt)를 subject에 실어 발행
            }
    }

    public enum TrackingError: Error {
        case notSupported
    }
}
