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
    
    init(service: EyeTrackingService) {
        self.service = service
    }
    
    func start(in arView: ARView) throws {
        try service.startTracking(in: arView)
    }
    
    func stop() { service.stopTracking() }
    
    var gazePublisher: AnyPublisher<CGPoint, Never> {
        service.gazePublisher
    }
}
