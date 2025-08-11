//
//  GazeCalibration.swift
//  Pree
//
//  Created by KimDogyung on 8/11/25.
//


// GazeCalibration.swift

import Foundation
import CoreGraphics

/// Holds the polynomial coefficients and applies the transformation.
struct GazeCalibration: GazeMapper {
    
    struct NormalizationParameters {
        let minX: Float
        let maxX: Float
        let minY: Float
        let maxY: Float
    }
    
    let xCoefficients: [Float]
    let yCoefficients: [Float]
    let normalization: NormalizationParameters
    
    // --- ⬇️ 클램핑을 위한 헬퍼 함수 추가 ⬇️ ---
    private func clamp(_ value: Float, to range: ClosedRange<Float>) -> Float {
        return min(max(value, range.lowerBound), range.upperBound)
    }
    // --- ⬆️ 헬퍼 함수 끝 ⬆️ ---

    /// Calculates the calibrated point from a raw gaze point.
    func calibratedPoint(for rawPoint: CGPoint) -> CGPoint {
        var normX = 2 * (Float(rawPoint.x) - normalization.minX) / (normalization.maxX - normalization.minX) - 1
        var normY = 2 * (Float(rawPoint.y) - normalization.minY) / (normalization.maxY - normalization.minY) - 1

        // --- ⬇️ 핵심 수정: 정규화된 값을 [-1, 1] 범위로 제한(클램핑) ⬇️ ---
        normX = clamp(normX, to: -1...1)
        normY = clamp(normY, to: -1...1)
        // --- ⬆️ 수정 끝 ⬆️ ---
        
        // The polynomial: c₀ + c₁x + c₂y + c₃xy + c₄x² + c₅y²
        let transform = { (coeffs: [Float], x: Float, y: Float) -> Float in
            return coeffs[0] +
                   coeffs[1] * x +
                   coeffs[2] * y +
                   coeffs[3] * x * y +
                   coeffs[4] * x * x +
                   coeffs[5] * y * y
        }
        
        let calibratedX = transform(xCoefficients, normX, normY)
        let calibratedY = transform(yCoefficients, normX, normY)
        
        return CGPoint(x: CGFloat(calibratedX), y: CGFloat(calibratedY))
    }
}
