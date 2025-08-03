//
//  EyeTrackingCalibrationService.swift
//  Pree
//
//  Created by KimDogyung on 8/2/25.
//

import Foundation
import Combine
import RealityKit

public protocol EyeTrackingService {
    /// Starts the face-tracking session.
    func startTracking(in arView: ARView) throws
    
    /// A Combine publisher that emits every time the user’s gaze moves on‐screen.
    var gazePublisher: AnyPublisher<CGPoint, Never> { get }
}
