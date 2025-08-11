//
//  AffineTransform.swift
//  Pree
//
//  Created by KimDogyung on 8/11/25.
//

// AffineTransform.swift

import Foundation
import CoreGraphics

/// 각 삼각형의 지역별 선형 변환(Affine Transformation)을 정의
struct AffineTransform {
    // Transformation: P' = M * P + T
    // M = [a, b]
    //     [c, d]
    // T = [tx]
    //     [ty]
    let a, b, c, d, tx, ty: CGFloat

    /// 세 쌍의 점(raw, target)으로 아핀 변환을 계산합니다.
    init?(raw: (p1: CGPoint, p2: CGPoint, p3: CGPoint), target: (p1: CGPoint, p2: CGPoint, p3: CGPoint)) {
        let (x1, y1) = (raw.p1.x, raw.p1.y)
        let (x2, y2) = (raw.p2.x, raw.p2.y)
        let (x3, y3) = (raw.p3.x, raw.p3.y)

        let (u1, v1) = (target.p1.x, target.p1.y)
        let (u2, v2) = (target.p2.x, target.p2.y)
        let (u3, v3) = (target.p3.x, target.p3.y)

        let det = (y2 - y3) * (x1 - x3) + (y3 - y1) * (x2 - x3)
        if abs(det) < 1e-9 { return nil } // 점들이 한 직선 위에 있으면 변환 불가

        a = ((y2 - y3) * (u1 - u3) + (y3 - y1) * (u2 - u3)) / det
        b = ((x3 - x2) * (u1 - u3) + (x1 - x3) * (u2 - u3)) / det
        c = ((y2 - y3) * (v1 - v3) + (y3 - y1) * (v2 - v3)) / det
        d = ((x3 - x2) * (v1 - v3) + (x1 - x3) * (v2 - v3)) / det
        tx = u3 - a * x3 - b * y3
        ty = v3 - c * x3 - d * y3
    }

    /// 주어진 점에 아핀 변환을 적용합니다.
    func apply(to point: CGPoint) -> CGPoint {
        let newX = a * point.x + b * point.y + tx
        let newY = c * point.x + d * point.y + ty
        return CGPoint(x: newX, y: newY)
    }
}
