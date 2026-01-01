//
//  StartCalibrationUseCase.swift
//  Pree
//
//  Created by KimDogyung on 8/2/25.
//

import Foundation
import RealityKit
import Combine


 final class EyeTrackingUseCase: EyeTrackingUseCaseProtocol {
    
    private let eyeTrackingService: EyeTrackingService
    private var calibrationService: CalibrationService?
    
    // --- ⬇️ 수동 보정값 프로퍼티 추가 ⬇️ ---
    // 이 값을 조절하여 최종 시선 위치를 미세 조정합니다.
    // 예: x를 양수로 하면 오른쪽으로, 음수로 하면 왼쪽으로 이동합니다.
    private var finalAdjustmentOffset: CGPoint = .zero
    
    init(service: EyeTrackingService) {
        self.eyeTrackingService = service
    }
    
    
    func setCalibration(calibrationService: CalibrationService) { 
        self.calibrationService = calibrationService
    }
    
    func start(in arView: ARView) throws {
        try eyeTrackingService.startTracking(in: arView)
    }
    
    func stop() { eyeTrackingService.stopTracking() }
    
    
    // --- 수동 보정값을 설정하는 함수 추가 ---
    /// 캘리브레이션 완료 후, 시선의 미세한 편향을 수동으로 조절
    /// - Parameters:
    ///   - x: 좌/우 보정값. 양수는 오른쪽, 음수는 왼쪽.
    ///   - y: 상/하 보정값. 양수는 아래쪽, 음수는 위쪽.
    public func setFinalAdjustment(x: CGFloat, y: CGFloat) {
        self.finalAdjustmentOffset = CGPoint(x: x, y: y)
    }
    
    var gazePublisher: AnyPublisher<CGPoint, Never> {
        eyeTrackingService.gazePublisher
            .map { [weak self] rawPoint in
                guard let self = self, let mapper = self.calibrationService else {
                    return rawPoint
                }
                // 1. 캘리브레이션 데이터가 있으면 보정 (CalibrationServiceImpl)
                // (IDW 보간법으로 부드럽게 오차 수정)
                let calibratedPoint = mapper.calibratedPoint(for: rawPoint)
                
                // 2. 수동 미세 조정 값 더하기 (offset)
                return CGPoint(
                    x: calibratedPoint.x + self.finalAdjustmentOffset.x,
                    y: calibratedPoint.y + self.finalAdjustmentOffset.y
                )
            }
            .eraseToAnyPublisher()
    }
    
}
