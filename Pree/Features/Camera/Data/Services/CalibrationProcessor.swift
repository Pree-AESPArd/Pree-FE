
// CalibrationProcessor.swift

import Foundation
import CoreGraphics

// Delaunay Triangulation을 위한 보조 구조체들
private struct Edge: Hashable { let i, j: Int }
private struct Circle { let center: CGPoint; let radiusSquared: CGFloat }

struct CalibrationProcessor {
    enum CalibrationError: Error {
        case notEnoughDataPoints
        case triangulationFailed
        case insufficientCleanData
    }

    private func robustCenter(of pts: [CGPoint]) -> CGPoint? {
        // 이전 답변에서 제공된 robustCenter 함수를 여기에 그대로 붙여넣어 주세요.
        // (Median + MAD 기반 이상치 제거 로직)
        guard !pts.isEmpty else { return nil }
        if pts.count < 3 { return pts.first } // 간단한 평균 또는 첫번째 값
        
        let xs = pts.map { $0.x }
        let ys = pts.map { $0.y }
        
        let mx = xs.sorted()[xs.count / 2]
        let my = ys.sorted()[ys.count / 2]
        
        let adx = xs.map { abs($0 - mx) }
        let ady = ys.map { abs($0 - my) }
        let madX = adx.sorted()[adx.count / 2]
        let madY = ady.sorted()[ady.count / 2]
        
        let c: CGFloat = 1.4826
        let k: CGFloat = 2.8
        let eps: CGFloat = 1.0
        
        let thrX = k * c * (madX == 0 ? eps : madX)
        let thrY = k * c * (madY == 0 ? eps : madY)
        
        let filtered = pts.filter { abs($0.x - mx) <= thrX && abs($0.y - my) <= thrY }
        
        if filtered.isEmpty { return CGPoint(x: mx, y: my) }
        
        let sumX = filtered.reduce(0) { $0 + $1.x }
        let sumY = filtered.reduce(0) { $0 + $1.y }
        return CGPoint(x: sumX / CGFloat(filtered.count), y: sumY / CGFloat(filtered.count))
    }

    /// 점들을 Delaunay 삼각형으로 분할합니다. (Bowyer-Watson 알고리즘)
    private func triangulate(points: [CGPoint]) -> [Triangle] {
        guard points.count >= 3 else { return [] }

        var triangles: [Triangle] = []
        let n = points.count
        
        // Super-triangle 생성 (모든 점을 포함하는 거대한 삼각형)
        var minX = points[0].x, minY = points[0].y
        var maxX = minX, maxY = minY
        for i in 1..<n {
            minX = min(minX, points[i].x); maxX = max(maxX, points[i].x)
            minY = min(minY, points[i].y); maxY = max(maxY, points[i].y)
        }
        let dx = maxX - minX, dy = maxY - minY
        let deltaMax = max(dx, dy)
        let midX = (minX + maxX) / 2, midY = (minY + maxY) / 2
        
        let p1 = CGPoint(x: midX - 20 * deltaMax, y: midY - deltaMax)
        let p2 = CGPoint(x: midX, y: midY + 20 * deltaMax)
        let p3 = CGPoint(x: midX + 20 * deltaMax, y: midY - deltaMax)
        
        var allPoints = points
        allPoints.append(contentsOf: [p1, p2, p3])
        
        triangles.append(Triangle(i: n, j: n + 1, k: n + 2))

        // 점들을 하나씩 추가하며 삼각분할 재구성
        for i in 0..<n {
            var edges: [Edge] = []
            var badTriangles: [Triangle] = []

            for triangle in triangles {
                let p1 = allPoints[triangle.i]
                let p2 = allPoints[triangle.j]
                let p3 = allPoints[triangle.k]

                let dx = p2.x - p1.x, dy = p2.y - p1.y
                let ex = p3.x - p1.x, ey = p3.y - p1.y
                
                let bl = dx * dx + dy * dy
                let cl = ex * ex + ey * ey
                let d = 2 * (dx * ey - dy * ex)
                
                if abs(d) < 1e-9 { continue }
                
                let cx = (ey * bl - dy * cl) / d + p1.x
                let cy = (dx * cl - ex * bl) / d + p1.y
                let center = CGPoint(x: cx, y: cy)
                let radiusSquared = pow(p1.x - cx, 2) + pow(p1.y - cy, 2)
                
                let distSquared = pow(allPoints[i].x - center.x, 2) + pow(allPoints[i].y - center.y, 2)

                if distSquared < radiusSquared {
                    badTriangles.append(triangle)
                    edges.append(Edge(i: triangle.i, j: triangle.j))
                    edges.append(Edge(i: triangle.j, j: triangle.k))
                    edges.append(Edge(i: triangle.k, j: triangle.i))
                }
            }
            
            triangles.removeAll { t in badTriangles.contains { $0.i == t.i && $0.j == t.j && $0.k == t.k } }
            
            var uniqueEdges: [Edge] = []
            for edge in edges {
                if edges.filter({ $0 == edge }).count == 1 {
                    uniqueEdges.append(edge)
                }
            }

            for edge in uniqueEdges {
                triangles.append(Triangle(i: edge.i, j: edge.j, k: i))
            }
        }

        // Super-triangle의 꼭짓점을 포함하는 삼각형 제거
        triangles.removeAll { $0.i >= n || $0.j >= n || $0.k >= n }
        
        return triangles
    }

    func calculate(targets: [CGPoint], samples: [[CGPoint]]) -> Result<PiecewiseCalibration, CalibrationError> {
        let minimumPointsPerTarget = 10
        
        var cleanedRaws: [CGPoint] = []
        var validTargets: [CGPoint] = []

        // 이상치 제거 및 유효한 타겟-샘플 쌍 생성
        for (index, pointArray) in samples.enumerated() {
            guard pointArray.count >= minimumPointsPerTarget,
                  let finalCenter = robustCenter(of: pointArray) else {
                continue
            }
            cleanedRaws.append(finalCenter)
            validTargets.append(targets[index])
        }

        guard validTargets.count >= 3 else {
            return .failure(.insufficientCleanData)
        }
        
        // 1. Delaunay Triangulation 수행
        let triangles = triangulate(points: cleanedRaws)
        
        guard !triangles.isEmpty else {
            return .failure(.triangulationFailed)
        }

        var rawTriangles: [(p1: CGPoint, p2: CGPoint, p3: CGPoint)] = []
        var transforms: [AffineTransform] = []

        // 2. 각 삼각형의 아핀 변환 계산
        for triangle in triangles {
            let rawP1 = cleanedRaws[triangle.i]
            let rawP2 = cleanedRaws[triangle.j]
            let rawP3 = cleanedRaws[triangle.k]

            let targetP1 = validTargets[triangle.i]
            let targetP2 = validTargets[triangle.j]
            let targetP3 = validTargets[triangle.k]

            if let transform = AffineTransform(raw: (rawP1, rawP2, rawP3), target: (targetP1, targetP2, targetP3)) {
                rawTriangles.append((rawP1, rawP2, rawP3))
                transforms.append(transform)
            }
        }
        
        return .success(PiecewiseCalibration(rawTriangles: rawTriangles, transforms: transforms))
    }
}





//// CalibrationProcessor.swift
//
//import Foundation
//import CoreGraphics
//import Accelerate
//
//struct CalibrationProcessor {
//
//    enum CalibrationError: Error {
//        case notEnoughDataPoints
//        case processingFailed
//        case insufficientCleanData
//    }
//    
//    // --- ⬇️ 헬퍼들: 평균, 중앙값, Robust Center(Median+MAD) ⬇️ ---
//    
//    /// CGPoint 배열의 평균 지점을 계산합니다.
//    private func mean(of points: [CGPoint]) -> CGPoint? {
//        guard !points.isEmpty else { return nil }
//        let sumX = points.reduce(0) { $0 + $1.x }
//        let sumY = points.reduce(0) { $0 + $1.y }
//        return CGPoint(x: sumX / CGFloat(points.count), y: sumY / CGFloat(points.count))
//    }
//    
//    /// CGFloat 배열의 중앙값
//    private func median(_ xs: [CGFloat]) -> CGFloat {
//        guard !xs.isEmpty else { return 0 }
//        let s = xs.sorted()
//        let m = s.count / 2
//        return s.count % 2 == 0 ? (s[m - 1] + s[m]) / 2 : s[m]
//    }
//    
//    /// Median + MAD(중앙절대편차)로 이상치를 제거하고, 남은 샘플의 평균(또는 중앙값)을 대표값으로 반환합니다.
//    /// - Parameters:
//    ///   - pts: 해당 타깃에서 수집된 시선 포인트들
//    ///   - k: 임계 배수(2.5~3 권장)
//    ///   - useMeanAfterFilter: 필터링 후 대표값을 평균으로 낼지(기본), 중앙값으로 낼지
//    private func robustCenter(of pts: [CGPoint],
//                              k: CGFloat = 2.8,
//                              useMeanAfterFilter: Bool = true) -> CGPoint? {
//        guard !pts.isEmpty else { return nil }
//        if pts.count < 3 { return mean(of: pts) } // 샘플이 적으면 그냥 평균
//        
//        let xs = pts.map { $0.x }
//        let ys = pts.map { $0.y }
//        
//        let mx = median(xs)
//        let my = median(ys)
//        
//        // 중앙절대편차(MAD)
//        let adx = xs.map { abs($0 - mx) }
//        let ady = ys.map { abs($0 - my) }
//        let madX = median(adx)
//        let madY = median(ady)
//        
//        // MAD -> σ 근사 상수
//        let c: CGFloat = 1.4826
//        // MAD가 0일 때(완전 정지 구간/양자화) 임계값이 0이 되지 않게 최소값 부여
//        let eps: CGFloat = 1.0
//        
//        let thrX = k * c * (madX == 0 ? eps : madX)
//        let thrY = k * c * (madY == 0 ? eps : madY)
//        
//        let filtered = pts.filter { abs($0.x - mx) <= thrX && abs($0.y - my) <= thrY }
//        
//        if filtered.isEmpty {
//            // 전부 걸러졌다면 중앙값 좌표를 사용
//            return CGPoint(x: mx, y: my)
//        } else {
//            // 남은 샘플의 대표값(평균 또는 중앙값)
//            if useMeanAfterFilter { return mean(of: filtered) }
//            let fxs = filtered.map { $0.x }
//            let fys = filtered.map { $0.y }
//            return CGPoint(x: median(fxs), y: median(fys))
//        }
//    }
//    
//    // --- ⬆️ 헬퍼 끝 ⬆️ ---
//
//    func calculate(targets: [CGPoint], samples: [[CGPoint]]) -> Result<GazeCalibration, CalibrationError> {
//        let numberOfCoefficients = 6 // 2차 다항식
//        
//        // --- ⬇️ 데이터 처리 로직: Median+MAD 기반 아웃라이어 제거로 변경 ⬇️ ---
//
//        let minimumPointsPerTarget = 10 // 필터링 전 최소 샘플 수
//        var cleanedAverageRaws: [CGPoint] = []
//        
//        for pointArray in samples {
//            guard pointArray.count >= minimumPointsPerTarget else { continue }
//            
//            // Robust center 추정 (Median+MAD로 이상치 제거)
//            guard let finalCenter = robustCenter(of: pointArray, k: 2.8, useMeanAfterFilter: true) else {
//                continue
//            }
//            cleanedAverageRaws.append(finalCenter)
//        }
//        
//        // 타깃 유효성 확인
//        guard cleanedAverageRaws.count >= numberOfCoefficients else {
//            return .failure(.insufficientCleanData)
//        }
//        
//        // 실제 구현에서는 targets와 samples 매칭을 안전하게 보장하세요 (여기선 동일 순서 가정)
//        let validTargets = targets.prefix(cleanedAverageRaws.count)
//        
//        // 2) 정규화
//        let rawXPoints = cleanedAverageRaws.map { Float($0.x) }
//        let rawYPoints = cleanedAverageRaws.map { Float($0.y) }
//        
//        guard let minX = rawXPoints.min(), let maxX = rawXPoints.max(),
//              let minY = rawYPoints.min(), let maxY = rawYPoints.max(),
//              (maxX - minX) > 0, (maxY - minY) > 0 else {
//            return .failure(.processingFailed)
//        }
//        
//        let normalizedRaws = cleanedAverageRaws.map { point -> (x: Float, y: Float) in
//            let normX = 2 * (Float(point.x) - minX) / (maxX - minX) - 1
//            let normY = 2 * (Float(point.y) - minY) / (maxY - minY) - 1
//            return (x: normX, y: normY)
//        }
//
//        // 3) 최소제곱 문제 설정
//        var aMatrix = [Float](repeating: 0, count: cleanedAverageRaws.count * numberOfCoefficients)
//        var bVectorX = validTargets.map { Float($0.x) }
//        var bVectorY = validTargets.map { Float($0.y) }
//
//        for (i, rawPoint) in normalizedRaws.enumerated() {
//            let x = rawPoint.x
//            let y = rawPoint.y
//            let rowStart = i * numberOfCoefficients
//            
//            aMatrix[rowStart + 0] = 1
//            aMatrix[rowStart + 1] = x
//            aMatrix[rowStart + 2] = y
//            aMatrix[rowStart + 3] = x * y
//            aMatrix[rowStart + 4] = x * x
//            aMatrix[rowStart + 5] = y * y
//        }
//        
//        // 4) 계수 풀이
//        let xCoefficients = solve(a: aMatrix, b: bVectorX, numSamples: cleanedAverageRaws.count, numCoeffs: numberOfCoefficients)
//        let yCoefficients = solve(a: aMatrix, b: bVectorY, numSamples: cleanedAverageRaws.count, numCoeffs: numberOfCoefficients)
//        
//        guard let xCoeffs = xCoefficients, let yCoeffs = yCoefficients else {
//            return .failure(.processingFailed)
//        }
//
//        let normParams = GazeCalibration.NormalizationParameters(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
//        return .success(GazeCalibration(xCoefficients: xCoeffs, yCoefficients: yCoeffs, normalization: normParams))
//    }
//
//    // Accelerate/BLAS를 이용한 선형 least-squares 풀이
//    private func solve(a: [Float], b: [Float], numSamples: Int, numCoeffs: Int) -> [Float]? {
//        var a_lapack = a
//        var b_lapack = b
//        var trans = CChar("N".utf8.first!)
//        
//        var m: __CLPK_integer = __CLPK_integer(numSamples)
//        var n: __CLPK_integer = __CLPK_integer(numCoeffs)
//        var nrhs: __CLPK_integer = 1
//        var lda: __CLPK_integer = m
//        var ldb: __CLPK_integer = m
//        var info: __CLPK_integer = 0
//        var work = [Float](repeating: 0, count: max(1, numSamples * numCoeffs))
//        var lwork: __CLPK_integer = -1
//
//        // 워크스페이스 쿼리
//        sgels_(&trans, &m, &n, &nrhs, &a_lapack, &lda, &b_lapack, &ldb, &work, &lwork, &info)
//        
//        lwork = __CLPK_integer(work[0])
//        work = [Float](repeating: 0, count: Int(max(1, lwork)))
//        
//        // 실제 계산
//        sgels_(&trans, &m, &n, &nrhs, &a_lapack, &lda, &b_lapack, &ldb, &work, &lwork, &info)
//
//        if info == 0 {
//            return Array(b_lapack.prefix(numCoeffs))
//        } else {
//            return nil
//        }
//    }
//}
