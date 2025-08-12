//
//  OffsetCalibration.swift
//  Pree
//
//  Created by KimDogyung on 8/12/25.
//

// OffsetCalibration.swift

import Foundation
import CoreGraphics

// MARK: - Helper Functions (Struct 외부의 보조 함수들)
// 이 함수들은 특정 구조체(Struct)에 속하지 않는 독립적인 도구(tool)들입니다.
// 구조체 내부에서 `self`가 완전히 초기화되기 전에 호출되어야 하므로 밖에 선언합니다.

/// Median+MAD(중앙값 절대 편차) 기반으로 이상치를 제거하고 데이터의 안정적인 중심점을 찾습니다.
/// 평균(mean)보다 이상치(outlier)에 훨씬 더 강건(robust)하여 데이터의 품질을 높입니다.
private func robustCenter(of pts: [CGPoint], k: CGFloat = 2.8) -> CGPoint? {
    // pts: 특정 목표점에서 수집된 시선 좌표들의 배열
    // k: 이상치를 판단하는 기준이 되는 임계값 배수 (클수록 관대함)
    
    guard !pts.isEmpty else { return nil }
    if pts.count < 3 { return mean(of: pts) } // 데이터가 너무 적으면 통계적 의미가 없으므로 일반 평균 사용
    
    // 1. X, Y 좌표를 각각 배열로 분리하고, 각 배열의 중앙값(median)을 계산합니다.
    // 중앙값은 데이터의 실제 중심을 이상치의 영향 없이 찾아냅니다.
    let xs = pts.map { $0.x }, ys = pts.map { $0.y }
    let mx = median(xs), my = median(ys)
    
    // 2. 중앙값 절대 편차(MAD)를 계산합니다. 데이터가 중앙값으로부터 얼마나 퍼져있는지를 나타냅니다.
    let madX = median(xs.map { abs($0 - mx) })
    let madY = median(ys.map { abs($0 - my) })
    
    // 3. 이상치를 제거할 경계선(threshold)을 설정합니다.
    // c는 MAD를 표준편차와 유사하게 만들어주는 상수입니다.
    let c: CGFloat = 1.4826, eps: CGFloat = 1.0 // eps: MAD가 0일 때를 대비한 최소값
    let thrX = k * c * (madX == 0 ? eps : madX)
    let thrY = k * c * (madY == 0 ? eps : madY)
    
    // 4. 경계선을 벗어나는 모든 점(이상치)을 걸러냅니다.
    let filtered = pts.filter { abs($0.x - mx) <= thrX && abs($0.y - my) <= thrY }
    
    // 5. 걸러낸 '깨끗한' 데이터의 평균을 최종 중심점으로 반환합니다.
    if filtered.isEmpty { return CGPoint(x: mx, y: my) } // 모두 걸러졌다면 중앙값을 사용
    return mean(of: filtered)
}

/// CGPoint 배열의 산술 평균을 계산하는 간단한 함수입니다.
private func mean(of points: [CGPoint]) -> CGPoint? {
    guard !points.isEmpty else { return nil }
    let sumX = points.reduce(0) { $0 + $1.x }; let sumY = points.reduce(0) { $0 + $1.y }
    return CGPoint(x: sumX / CGFloat(points.count), y: sumY / CGFloat(points.count))
}


/// 숫자(CGFloat) 배열의 중앙값을 계산하는 함수입니다.
private func median(_ xs: [CGFloat]) -> CGFloat {
    guard !xs.isEmpty else { return 0 }
    let s = xs.sorted(), m = s.count / 2 // 배열을 정렬한 후 가운데 인덱스를 찾습니다.
    return s.count % 2 == 0 ? (s[m - 1] + s[m]) / 2 : s[m]  // 짝수/홀수 개수에 따라 중앙값을 반환합니다.
}


// MARK: - Main Struct
/// 최근접 이웃 오프셋 보정 모델
struct CalibrationServiceImpl: CalibrationService {
    
    /// 캘리브레이션 기준점(노드)의 정보를 담는 내부 구조체입니다.
    private struct CalibrationNode {
        let rawPoint: CGPoint   // 이상치가 제거된, 사용자의 평균 시선 좌표
        let offset: CGPoint     // 보정을 위해 더해줘야 할 오차 값 (목표점 - 평균 시선)
    }
    
    private let nodes: [CalibrationNode]    // 캘리브레이션으로 생성된 13개의 기준점(노드) 배열
    private let kNeighbors = 3              // 보정 시 참고할 가장 가까운 이웃의 수 (값이 클수록 부드러워짐)
    
    /// 초기화 메서드: 캘리브레이션 데이터로 보정 모델(노드 배열)을 생성합니다.
    init?(targets: [CGPoint], samples: [[CGPoint]]) {
        // targets: 화면에 표시됐던 목표점들의 실제 좌표
        // samples: 각 목표점을 응시할 때 수집된 사용자의 시선 좌표들
        
        guard targets.count == samples.count, targets.count >= kNeighbors else { return nil }
        
        var tempNodes: [CalibrationNode] = []
        for i in 0..<targets.count {
            // 1. 각 목표점의 샘플 데이터에서 이상치를 제거하고 안정적인 중심점을 찾습니다.
            guard let rawMean = robustCenter(of: samples[i]) else { continue }
            
            // 2. '실제 목표점'과 '사용자의 평균 시선' 사이의 오차(offset)를 계산합니다.
            let offset = CGPoint(x: targets[i].x - rawMean.x, y: targets[i].y - rawMean.y)
            
            // 3. 계산된 정보를 바탕으로 새로운 보정 노드를 만들어 배열에 추가합니다.
            tempNodes.append(CalibrationNode(rawPoint: rawMean, offset: offset))
        }
        
        if tempNodes.count < kNeighbors { return nil }  // 유효한 노드가 충분하지 않으면 모델 생성을 실패시킵니다.
        self.nodes = tempNodes  // 최종적으로 생성된 노드들을 저장합니다.
    }
    
    /// 실시간으로 들어온 rawPoint를 보간법(Interpolation)으로 보정합니다.
    func calibratedPoint(for rawPoint: CGPoint) -> CGPoint {
        // rawPoint: ARKit으로부터 실시간으로 들어오는 '날것의' 시선 좌표
        
        // 1. 현재 시선(rawPoint)과 가장 가까운 k개의 보정 노드를 찾습니다.
        let nearest = findKNearestNodes(to: rawPoint, k: kNeighbors)
        
        var totalWeight: CGFloat = 0       // 가중치의 총합
        var weightedOffsetX: CGFloat = 0   // 가중치가 적용된 X 오프셋의 합
        var weightedOffsetY: CGFloat = 0   // 가중치가 적용된 Y 오프셋의 합
        
        for (node, distance) in nearest {
            // 거리가 0에 매우 가까우면(즉, 기준점 바로 위), 해당 노드의 오프셋을 바로 사용합니다. (0으로 나누는 오류 방지)
            if distance < 1e-6 {
                return CGPoint(x: rawPoint.x + node.offset.x, y: rawPoint.y + node.offset.y)
            }
            
            // 2. '역거리 가중법(IDW)': 거리에 반비례하는 가중치를 계산합니다.
            // 즉, 가까운 노드일수록 더 큰 영향력을 가집니다.
            let weight = 1.0 / distance
            
            // 3. 각 노드의 오프셋에 가중치를 곱하여 누적합니다.
            weightedOffsetX += node.offset.x * weight
            weightedOffsetY += node.offset.y * weight
            totalWeight += weight
        }
        
        if totalWeight == 0 { return rawPoint } // 예외 처리
        
        // 4. 누적된 가중치 오프셋을 총 가중치로 나누어, 최종 오프셋의 '가중 평균'을 구합니다.
        let finalOffsetX = weightedOffsetX / totalWeight
        let finalOffsetY = weightedOffsetY / totalWeight
        
        // 5. 계산된 최종 오프셋을 현재 시선(rawPoint)에 더하여 부드럽게 보정된 최종 좌표를 반환합니다.
        return CGPoint(x: rawPoint.x + finalOffsetX, y: rawPoint.y + finalOffsetY)
    }
    
    /// 주어진 점과 가장 가까운 k개의 노드를 거리와 함께 찾아 반환하는 헬퍼 함수입니다.
    private func findKNearestNodes(to point: CGPoint, k: Int) -> [(node: CalibrationNode, distance: CGFloat)] {
        // 모든 노드와의 거리를 계산하고, 거리가 가까운 순으로 정렬합니다.
        let sortedNodes = nodes.map { node -> (node: CalibrationNode, distance: CGFloat) in
            let distance = hypot(point.x - node.rawPoint.x, point.y - node.rawPoint.y) // 유클리드 거리 계산
            return (node, distance)
        }.sorted(by: { $0.distance < $1.distance })
        
        // 가장 가까운 k개만 잘라서 반환합니다.
        return Array(sortedNodes.prefix(k))
    }
}
