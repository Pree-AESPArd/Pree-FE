////
////  PiecewiseCalibration.swift
////  Pree
////
////  Created by KimDogyung on 8/11/25.
////
//
//// PiecewiseCalibration.swift
//
//import Foundation
//import CoreGraphics
//
///// Piecewise Triangle 방식의 보정 모델
//struct PiecewiseCalibration: GazeMapper {
//    let rawTriangles: [(p1: CGPoint, p2: CGPoint, p3: CGPoint)]
//    let transforms: [AffineTransform]
//
//    /// 실시간으로 들어온 점을 보정합니다.
//    func calibratedPoint(for rawPoint: CGPoint) -> CGPoint {
//        // 1. rawPoint가 어느 rawTriangle 내부에 있는지 찾습니다.
//        for i in 0..<rawTriangles.count {
//            let triangle = rawTriangles[i]
//            if getBarycentricCoordinate(p: rawPoint, a: triangle.p1, b: triangle.p2, c: triangle.p3) != nil {
//                // 2. 해당 삼각형의 변환 규칙을 적용합니다.
//                return transforms[i].apply(to: rawPoint)
//            }
//        }
//        
//        // 3. 만약 어떤 삼각형에도 속하지 않으면(가장자리 밖), 가장 가까운 삼각형의 변환을 적용합니다 (Fallback).
//        var minDistance = CGFloat.greatestFiniteMagnitude
//        var closestTransform: AffineTransform?
//        
//        for i in 0..<rawTriangles.count {
//            let triangle = rawTriangles[i]
//            let center = CGPoint(x: (triangle.p1.x + triangle.p2.x + triangle.p3.x) / 3,
//                                 y: (triangle.p1.y + triangle.p2.y + triangle.p3.y) / 3)
//            let distance = hypot(rawPoint.x - center.x, rawPoint.y - center.y)
//            
//            if distance < minDistance {
//                minDistance = distance
//                closestTransform = transforms[i]
//            }
//        }
//
//        return closestTransform?.apply(to: rawPoint) ?? rawPoint
//    }
//}
