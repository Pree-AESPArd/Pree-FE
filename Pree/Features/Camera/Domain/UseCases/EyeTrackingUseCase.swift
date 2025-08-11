//
//  StartCalibrationUseCase.swift
//  Pree
//
//  Created by KimDogyung on 8/2/25.
//

import Foundation
import RealityKit
import Combine


final class EyeTrackingUseCase {
    
    private let service: EyeTrackingService
    private var mapper: GazeMapper?
    
    init(service: EyeTrackingService) {
        self.service = service
    }
    
    
    func setCalibration(mapper: GazeMapper) { // <--- 파라미터 타입 변경
        self.mapper = mapper
    }
    
    func start(in arView: ARView) throws {
        try service.startTracking(in: arView)
    }
    
    func stop() { service.stopTracking() }
    
//    var gazePublisher: AnyPublisher<CGPoint, Never> {
//        service.gazePublisher
//    }
    
    var gazePublisher: AnyPublisher<CGPoint, Never> {
        service.gazePublisher
            .map { [weak self] rawPoint in
                guard let self = self, let mapper = self.mapper else {
                    return rawPoint
                }
                // 어떤 종류의 모델이든 상관없이, 역할(calibratedPoint 함수)을 수행
                return mapper.calibratedPoint(for: rawPoint) // <--- mapper 사용
            }
            .eraseToAnyPublisher()
    }
    
}
