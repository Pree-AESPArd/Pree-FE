//
//  GazeMapper.swift
//  Pree
//
//  Created by KimDogyung on 8/11/25.
//

import CoreGraphics

/// '날것의' 시선 좌표를 보정된 좌표로 매핑하는 역할을 정의하는 프로토콜
protocol CalibrationService {
    func calibratedPoint(for rawPoint: CGPoint) -> CGPoint
}
