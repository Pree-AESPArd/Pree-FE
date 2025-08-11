//
//  OffsetCalibration.swift
//  Pree
//
//  Created by KimDogyung on 8/12/25.
//

// OffsetCalibration.swift

import Foundation
import CoreGraphics

// MARK: - Helper Functions (Struct 외부로 이동)

/// Median+MAD 기반 이상치 제거 및 평균 계산
private func robustCenter(of pts: [CGPoint], k: CGFloat = 2.8) -> CGPoint? {
    guard !pts.isEmpty else { return nil }
    if pts.count < 3 { return mean(of: pts) }
    
    let xs = pts.map { $0.x }, ys = pts.map { $0.y }
    let mx = median(xs), my = median(ys)
    
    let madX = median(xs.map { abs($0 - mx) })
    let madY = median(ys.map { abs($0 - my) })
    
    let c: CGFloat = 1.4826, eps: CGFloat = 1.0
    let thrX = k * c * (madX == 0 ? eps : madX)
    let thrY = k * c * (madY == 0 ? eps : madY)
    
    let filtered = pts.filter { abs($0.x - mx) <= thrX && abs($0.y - my) <= thrY }
    
    if filtered.isEmpty { return CGPoint(x: mx, y: my) }
    return mean(of: filtered)
}

private func mean(of points: [CGPoint]) -> CGPoint? {
    guard !points.isEmpty else { return nil }
    let sumX = points.reduce(0) { $0 + $1.x }; let sumY = points.reduce(0) { $0 + $1.y }
    return CGPoint(x: sumX / CGFloat(points.count), y: sumY / CGFloat(points.count))
}

private func median(_ xs: [CGFloat]) -> CGFloat {
    guard !xs.isEmpty else { return 0 }
    let s = xs.sorted(), m = s.count / 2
    return s.count % 2 == 0 ? (s[m - 1] + s[m]) / 2 : s[m]
}


// MARK: - Main Struct
/// 최근접 이웃 오프셋 보정 모델
struct OffsetCalibration: GazeMapper {
    
    private struct CalibrationNode {
        let rawPoint: CGPoint
        let offset: CGPoint
    }
    
    private let nodes: [CalibrationNode]
    private let kNeighbors = 3 // 참고할 이웃의 수 (3 또는 4 권장)

    init?(targets: [CGPoint], samples: [[CGPoint]]) {
        guard targets.count == samples.count, targets.count >= kNeighbors else { return nil }
        
        var tempNodes: [CalibrationNode] = []
        for i in 0..<targets.count {
            guard let rawMean = robustCenter(of: samples[i]) else { continue }
            let offset = CGPoint(x: targets[i].x - rawMean.x, y: targets[i].y - rawMean.y)
            tempNodes.append(CalibrationNode(rawPoint: rawMean, offset: offset))
        }
        
        if tempNodes.count < kNeighbors { return nil }
        self.nodes = tempNodes
    }
    
    /// 실시간으로 들어온 rawPoint를 보간법으로 보정합니다.
    func calibratedPoint(for rawPoint: CGPoint) -> CGPoint {
        // 1. 가장 가까운 k개의 노드를 찾습니다.
        let nearest = findKNearestNodes(to: rawPoint, k: kNeighbors)
        
        var totalWeight: CGFloat = 0
        var weightedOffsetX: CGFloat = 0
        var weightedOffsetY: CGFloat = 0
        
        for (node, distance) in nearest {
            // 거리가 0에 매우 가까우면, 해당 노드의 오프셋을 바로 사용 (0으로 나누기 방지)
            if distance < 1e-6 {
                return CGPoint(x: rawPoint.x + node.offset.x, y: rawPoint.y + node.offset.y)
            }
            
            // 2. 거리의 역수로 가중치를 계산합니다. (가까울수록 가중치가 커짐)
            let weight = 1.0 / distance
            
            weightedOffsetX += node.offset.x * weight
            weightedOffsetY += node.offset.y * weight
            totalWeight += weight
        }
        
        if totalWeight == 0 { return rawPoint }
        
        // 3. 오프셋의 가중 평균을 계산합니다.
        let finalOffsetX = weightedOffsetX / totalWeight
        let finalOffsetY = weightedOffsetY / totalWeight
        
        // 4. 최종 보정값을 적용합니다.
        return CGPoint(x: rawPoint.x + finalOffsetX, y: rawPoint.y + finalOffsetY)
    }
    
    /// 주어진 점과 가장 가까운 k개의 노드를 거리와 함께 찾습니다.
    private func findKNearestNodes(to point: CGPoint, k: Int) -> [(node: CalibrationNode, distance: CGFloat)] {
        let sortedNodes = nodes.map { node -> (node: CalibrationNode, distance: CGFloat) in
            let distance = hypot(point.x - node.rawPoint.x, point.y - node.rawPoint.y)
            return (node, distance)
        }.sorted(by: { $0.distance < $1.distance })
        
        return Array(sortedNodes.prefix(k))
    }
}
