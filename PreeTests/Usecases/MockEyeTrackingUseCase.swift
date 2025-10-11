//
//  MockEyeTrackingUseCase.swift
//  Pree
//
//  Created by KimDogyung on 10/11/25.
//

import Foundation
import Combine
import RealityKit
@testable import Pree // @testable을 사용해 internal 타입에 접근


final class MockEyeTrackingUseCase: EyeTrackingUseCaseProtocol {
    var gazePublisher: AnyPublisher<CGPoint, Never> {
        // 테스트용 Publisher.
        // 필요에 따라 emit하는 값을 변경 가능
        Just(CGPoint(x: 100, y: 200))
            .eraseToAnyPublisher()
    }

    var startCalled = false
    var stopCalled = false
    var setCalibrationCalled = false
    var setFinalAdjustmentCalled = false

    func setCalibration(calibrationService: CalibrationService) {
        setCalibrationCalled = true
    }

    func start(in arView: ARView) throws {
        startCalled = true
    }

    func stop() {
        stopCalled = true
    }
    
    func setFinalAdjustment(x: CGFloat, y: CGFloat) {
        setFinalAdjustmentCalled = true
    }
}
