//
//  EyeTrackingCalibrationService.swift
//  Pree
//
//  Created by KimDogyung on 8/2/25.
//

import Foundation
import Combine
import RealityKit
import ARKit


public protocol EyeTrackingService {
    /// Starts the face-tracking session.
    func startTracking(in arView: ARView) throws
    
    func stopTracking()
    
    /// A Combine publisher that emits every time the user’s gaze moves on‐screen.
    var gazePublisher: AnyPublisher<CGPoint, Never> { get }
    
    var currentFaceAnchor: ARFaceAnchor? { get } // ML 때문에 추가
}
