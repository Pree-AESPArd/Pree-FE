////
////  Triangle.swift
////  Pree
////
////  Created by KimDogyung on 8/11/25.
////
//
//// Triangle.swift
//
//import Foundation
//import CoreGraphics
//
///// 3개의 꼭짓점 인덱스로 삼각형을 정의하는 구조체
//struct Triangle {
//    let i: Int
//    let j: Int
//    let k: Int
//}
//
///// Barycentric 좌표를 계산하고 점이 내부에 있는지 확인하는 로직
//func getBarycentricCoordinate(p: CGPoint, a: CGPoint, b: CGPoint, c: CGPoint) -> (u: CGFloat, v: CGFloat, w: CGFloat)? {
//    let v0 = CGPoint(x: b.x - a.x, y: b.y - a.y)
//    let v1 = CGPoint(x: c.x - a.x, y: c.y - a.y)
//    let v2 = CGPoint(x: p.x - a.x, y: p.y - a.y)
//    
//    let d00 = v0.x * v0.x + v0.y * v0.y
//    let d01 = v0.x * v1.x + v0.y * v1.y
//    let d11 = v1.x * v1.x + v1.y * v1.y
//    let d20 = v2.x * v0.x + v2.y * v0.y
//    let d21 = v2.x * v1.x + v2.y * v1.y
//    
//    let denom = d00 * d11 - d01 * d01
//    if abs(denom) < 1e-9 { return nil } // 삼각형이 직선일 경우 (면적이 0)
//    
//    let v = (d11 * d20 - d01 * d21) / denom
//    let w = (d00 * d21 - d01 * d20) / denom
//    let u = 1.0 - v - w
//    
//    // 점이 삼각형 내부에 있거나 경계에 있을 조건
//    if u >= 0 && v >= 0 && w >= 0 {
//        return (u, v, w)
//    }
//    
//    return nil
//}
