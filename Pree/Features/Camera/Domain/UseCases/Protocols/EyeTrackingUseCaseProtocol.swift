//
//  EyeTrackingUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 10/11/25.
//

import Foundation
import ReplayKit
import RealityKit
import Combine

public protocol EyeTrackingUseCaseProtocol {
    func setCalibration(calibrationService: CalibrationService)
    func start(in arView: ARView) throws
    func stop()
    func setFinalAdjustment(x: CGFloat, y: CGFloat)
    var gazePublisher: AnyPublisher<CGPoint, Never> { get }
}
