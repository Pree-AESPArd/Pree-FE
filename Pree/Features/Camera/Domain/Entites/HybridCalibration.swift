////
////  HybridCalibration.swift
////  Pree
////
////  Created by KimDogyung on 8/12/25.
////
//
//
//
//import Foundation
//import CoreGraphics
//
//// --- ⬇️ GazePolynomial 정의를 이곳으로 이동 ⬇️ ---
///// 다항식 모델의 정의와 예측 로직을 담는 구조체
//struct GazePolynomial {
//    let xCoefficients: [Float]
//    let yCoefficients: [Float]
//    let normalization: NormalizationParameters
//    
//    struct NormalizationParameters {
//        let minX: Float, maxX: Float, minY: Float, maxY: Float
//    }
//
//    /// 주어진 점에 다항식 변환을 적용하여 예측값을 반환합니다.
//    func predict(_ point: CGPoint) -> CGPoint {
//        var normX = 2 * (Float(point.x) - normalization.minX) / (normalization.maxX - normalization.minX) - 1
//        var normY = 2 * (Float(point.y) - normalization.minY) / (normalization.maxY - normalization.minY) - 1
//        
//        // 클램핑 추가
//        normX = min(max(normX, -1), 1)
//        normY = min(max(normY, -1), 1)
//
//        let transform = { (coeffs: [Float], x: Float, y: Float) -> Float in
//            return coeffs[0] + coeffs[1] * x + coeffs[2] * y + coeffs[3] * x * y + coeffs[4] * x * x + coeffs[5] * y * y
//        }
//        
//        return CGPoint(x: CGFloat(transform(xCoefficients, normX, normY)),
//                       y: CGFloat(transform(yCoefficients, normX, normY)))
//    }
//}
//// --- ⬆️ GazePolynomial 정의 끝 ⬆️ ---
//
//
///// Piecewise Triangle 모델과 Residual Polynomial 모델을 결합한 하이브리드 보정 모델
//struct HybridCalibration: GazeMapper {
//    private let piecewiseModel: PiecewiseCalibration
//    
//    // --- ⬇️ 타입을 GazeCalibration -> GazePolynomial 로 변경 ⬇️ ---
//    private let residualPolynomial: GazePolynomial
//
//    init(piecewiseModel: PiecewiseCalibration, residualPolynomial: GazePolynomial) {
//        self.piecewiseModel = piecewiseModel
//        self.residualPolynomial = residualPolynomial
//    }
//    // --- ⬆️ 타입 변경 끝 ⬆️ ---
//
//    /// 실시간으로 들어온 점을 하이브리드 방식으로 보정합니다.
//    func calibratedPoint(for rawPoint: CGPoint) -> CGPoint {
//        // 1단계: Piecewise 모델로 1차 보정을 수행 (초벌 작업)
//        let primaryCorrectedPoint = piecewiseModel.calibratedPoint(for: rawPoint)
//
//        // 2단계: 다항식 모델로 잔차(residual)를 예측 (마감 작업)
//        let residualCorrection = residualPolynomial.predict(rawPoint) // <-- .predict() 호출로 변경
//
//        // 3단계: 1차 보정값에 잔차 보정값을 더하여 최종 좌표를 얻음
//        return CGPoint(
//            x: primaryCorrectedPoint.x + residualCorrection.x,
//            y: primaryCorrectedPoint.y + residualCorrection.y
//        )
//    }
//}
