////
////    HybridCalibrationProcessor.swift
////  Pree
////
////  Created by KimDogyung on 8/12/25.
////
//
//import Foundation
//import CoreGraphics
//import Accelerate
//
//// MARK: - 보조 타입 정의
//fileprivate struct Edge: Hashable { let i, j: Int }
//
//
///// 하이브리드 캘리브레이션 모델을 생성하는 최종 처리기
//struct HybridCalibrationProcessor {
//
//    enum CalibrationError: Error {
//        case notEnoughDataPoints
//        case processingFailed
//        case insufficientCleanData
//        case triangulationFailed
//    }
//
//    /// 메인 계산 함수: 하이브리드 모델을 생성합니다.
//    func calculate(targets: [CGPoint], samples: [[CGPoint]]) -> Result<HybridCalibration, CalibrationError> {
//        
//        // --- 1단계: 데이터 정제 ---
//        // Robust Center (Median+MAD)를 사용하여 이상치를 제거하고 깨끗한 평균 좌표를 계산합니다.
//        var cleanedRaws: [CGPoint] = []
//        var validTargets: [CGPoint] = []
//        for (index, pointArray) in samples.enumerated() {
//            guard pointArray.count >= 10, let center = robustCenter(of: pointArray) else { continue }
//            cleanedRaws.append(center)
//            validTargets.append(targets[index])
//        }
//
//        // 유효한 데이터가 충분한지 확인
//        guard validTargets.count >= 6 else { return .failure(.insufficientCleanData) }
//
//        // --- 2단계: Piecewise 모델 생성 (초벌 작업) ---
//        let triangles = triangulate(points: cleanedRaws)
//        guard !triangles.isEmpty else { return .failure(.triangulationFailed) }
//
//        var rawTriangles: [(p1: CGPoint, p2: CGPoint, p3: CGPoint)] = []
//        var transforms: [AffineTransform] = []
//        for triangle in triangles {
//            let rawP1 = cleanedRaws[triangle.i], rawP2 = cleanedRaws[triangle.j], rawP3 = cleanedRaws[triangle.k]
//            let targetP1 = validTargets[triangle.i], targetP2 = validTargets[triangle.j], targetP3 = validTargets[triangle.k]
//            if let transform = AffineTransform(raw: (rawP1, rawP2, rawP3), target: (targetP1, targetP2, targetP3)) {
//                rawTriangles.append((rawP1, rawP2, rawP3))
//                transforms.append(transform)
//            }
//        }
//        let piecewiseModel = PiecewiseCalibration(rawTriangles: rawTriangles, transforms: transforms)
//
//        // --- 3단계: 잔차(Residual) 계산 ---
//        // 1차 보정 후 남은 오차(잔차)를 계산합니다.
//        var residuals: [CGPoint] = []
//        for i in 0..<cleanedRaws.count {
//            let primaryCorrectedPoint = piecewiseModel.calibratedPoint(for: cleanedRaws[i])
//            residuals.append(CGPoint(x: validTargets[i].x - primaryCorrectedPoint.x,
//                                     y: validTargets[i].y - primaryCorrectedPoint.y))
//        }
//
//        // --- 4단계: 잔차를 학습하는 다항식 모델 생성 (마감 작업) ---
//        guard let residualPolynomial = createPolynomialModel(raws: cleanedRaws, targets: residuals) else {
//            return .failure(.processingFailed)
//        }
//        
//        // --- 5단계: 두 모델을 결합한 하이브리드 모델 반환 ---
//        let hybridModel = HybridCalibration(piecewiseModel: piecewiseModel, residualPolynomial: residualPolynomial)
//        return .success(hybridModel)
//    }
//
//    // MARK: - Private Helper Functions
//    
//    /// Median+MAD로 이상치를 제거하고, 남은 샘플의 평균을 대표값으로 반환합니다.
//    private func robustCenter(of pts: [CGPoint], k: CGFloat = 2.8) -> CGPoint? {
//        guard !pts.isEmpty else { return nil }
//        if pts.count < 3 { return mean(of: pts) }
//        
//        let xs = pts.map { $0.x }, ys = pts.map { $0.y }
//        let mx = median(xs), my = median(ys)
//        
//        let madX = median(xs.map { abs($0 - mx) })
//        let madY = median(ys.map { abs($0 - my) })
//        
//        let c: CGFloat = 1.4826, eps: CGFloat = 1.0
//        let thrX = k * c * (madX == 0 ? eps : madX)
//        let thrY = k * c * (madY == 0 ? eps : madY)
//        
//        let filtered = pts.filter { abs($0.x - mx) <= thrX && abs($0.y - my) <= thrY }
//        
//        if filtered.isEmpty { return CGPoint(x: mx, y: my) }
//        return mean(of: filtered)
//    }
//
//    /// 다항식 모델을 생성합니다.
//    private func createPolynomialModel(raws: [CGPoint], targets: [CGPoint]) -> GazePolynomial? {
//        let numCoeffs = 6
//        guard raws.count >= numCoeffs else { return nil }
//
//        let rawX = raws.map { Float($0.x) }, rawY = raws.map { Float($0.y) }
//        guard let minX = rawX.min(), let maxX = rawX.max(),
//              let minY = rawY.min(), let maxY = rawY.max(),
//              (maxX - minX) > 0, (maxY - minY) > 0 else { return nil }
//        
//        let normalizedRaws = raws.map { p -> (x: Float, y: Float) in
//            (x: 2 * (Float(p.x) - minX) / (maxX - minX) - 1,
//             y: 2 * (Float(p.y) - minY) / (maxY - minY) - 1)
//        }
//
//        var aMatrix = [Float](repeating: 0, count: raws.count * numCoeffs)
//        var bVectorX = targets.map { Float($0.x) }
//        var bVectorY = targets.map { Float($0.y) }
//
//        for (i, p) in normalizedRaws.enumerated() {
//            let rowStart = i * numCoeffs
//            aMatrix[rowStart+0]=1; aMatrix[rowStart+1]=p.x; aMatrix[rowStart+2]=p.y;
//            aMatrix[rowStart+3]=p.x*p.y; aMatrix[rowStart+4]=p.x*p.x; aMatrix[rowStart+5]=p.y*p.y;
//        }
//        
//        guard let xCoeffs = solve(a: aMatrix, b: bVectorX, numSamples: raws.count, numCoeffs: numCoeffs),
//              let yCoeffs = solve(a: aMatrix, b: bVectorY, numSamples: raws.count, numCoeffs: numCoeffs) else {
//            return nil
//        }
//        
//        let normParams = GazePolynomial.NormalizationParameters(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
//        return GazePolynomial(xCoefficients: xCoeffs, yCoefficients: yCoeffs, normalization: normParams)
//    }
//
//    /// 점들을 Delaunay 삼각형으로 분할합니다.
//    private func triangulate(points: [CGPoint]) -> [Triangle] {
//        guard points.count >= 3 else { return [] }
//        var triangles: [Triangle] = []; let n = points.count
//        var allPoints = points
//        let (p1, p2, p3) = createSuperTriangle(points: points)
//        allPoints.append(contentsOf: [p1, p2, p3])
//        triangles.append(Triangle(i: n, j: n + 1, k: n + 2))
//
//        for i in 0..<n {
//            var edges: [Edge] = [], badTrianglesIndices: [Int] = []
//            for (ti, triangle) in triangles.enumerated() {
//                if isPointInCircumcircle(point: allPoints[i], trianglePoints: (allPoints[triangle.i], allPoints[triangle.j], allPoints[triangle.k])) {
//                    badTrianglesIndices.append(ti)
//                    edges.append(Edge(i: triangle.i, j: triangle.j)); edges.append(Edge(i: triangle.j, j: triangle.k)); edges.append(Edge(i: triangle.k, j: triangle.i))
//                }
//            }
//            for index in badTrianglesIndices.sorted(by: >) { triangles.remove(at: index) }
//            let uniqueEdges = findUniqueEdges(edges)
//            for edge in uniqueEdges { triangles.append(Triangle(i: edge.i, j: edge.j, k: i)) }
//        }
//        triangles.removeAll { $0.i >= n || $0.j >= n || $0.k >= n }
//        return triangles
//    }
//    
//    // MARK: - Low-Level Helpers (for robustCenter, triangulate, solve)
//    private func mean(of points: [CGPoint]) -> CGPoint? {
//        guard !points.isEmpty else { return nil }
//        let sumX = points.reduce(0) { $0 + $1.x }; let sumY = points.reduce(0) { $0 + $1.y }
//        return CGPoint(x: sumX / CGFloat(points.count), y: sumY / CGFloat(points.count))
//    }
//    private func median(_ xs: [CGFloat]) -> CGFloat {
//        guard !xs.isEmpty else { return 0 }
//        let s = xs.sorted(), m = s.count / 2
//        return s.count % 2 == 0 ? (s[m - 1] + s[m]) / 2 : s[m]
//    }
//    private func createSuperTriangle(points: [CGPoint]) -> (CGPoint, CGPoint, CGPoint) {
//        var minX = points[0].x, minY = points[0].y, maxX = minX, maxY = minY
//        for i in 1..<points.count {
//            minX = min(minX, points[i].x); maxX = max(maxX, points[i].x)
//            minY = min(minY, points[i].y); maxY = max(maxY, points[i].y)
//        }
//        let dx = maxX - minX, dy = maxY - minY, dmax = max(dx, dy)
//        let midX = (minX + maxX) / 2, midY = (minY + maxY) / 2
//        return (CGPoint(x: midX - 20 * dmax, y: midY - dmax),
//                CGPoint(x: midX, y: midY + 20 * dmax),
//                CGPoint(x: midX + 20 * dmax, y: midY - dmax))
//    }
//    private func isPointInCircumcircle(point p: CGPoint, trianglePoints t: (p1: CGPoint, p2: CGPoint, p3: CGPoint)) -> Bool {
//        let (p1,p2,p3) = t
//        let d = 2 * (p1.x * (p2.y - p3.y) + p2.x * (p3.y - p1.y) + p3.x * (p1.y - p2.y))
//        if abs(d) < 1e-9 { return false }
//        let p1sq = p1.x * p1.x + p1.y * p1.y, p2sq = p2.x * p2.x + p2.y * p2.y, p3sq = p3.x * p3.x + p3.y * p3.y
//        let cx = (p1sq * (p2.y - p3.y) + p2sq * (p3.y - p1.y) + p3sq * (p1.y - p2.y)) / d
//        let cy = (p1sq * (p3.x - p2.x) + p2sq * (p1.x - p3.x) + p3sq * (p2.x - p1.x)) / d
//        let radiusSq = (p1.x - cx) * (p1.x - cx) + (p1.y - cy) * (p1.y - cy)
//        let distSq = (p.x - cx) * (p.x - cx) + (p.y - cy) * (p.y - cy)
//        return distSq < radiusSq
//    }
//    private func findUniqueEdges(_ edges: [Edge]) -> [Edge] {
//        var edgeCount: [Edge: Int] = [:]
//        for edge in edges { let sortedEdge = Edge(i: min(edge.i, edge.j), j: max(edge.i, edge.j)); edgeCount[sortedEdge, default: 0] += 1 }
//        return edgeCount.filter { $0.value == 1 }.map { $0.key }
//    }
//    private func solve(a: [Float], b: [Float], numSamples: Int, numCoeffs: Int) -> [Float]? {
//        var a_lapack=a, b_lapack=b; var trans = CChar("N".utf8.first!)
//        var m: __CLPK_integer=__CLPK_integer(numSamples), n: __CLPK_integer=__CLPK_integer(numCoeffs)
//        var nrhs: __CLPK_integer=1, lda: __CLPK_integer=m, ldb: __CLPK_integer=m
//        var info: __CLPK_integer=0, lwork: __CLPK_integer = -1
//        var work = [Float](repeating:0, count:1)
//        sgels_(&trans, &m, &n, &nrhs, &a_lapack, &lda, &b_lapack, &ldb, &work, &lwork, &info)
//        lwork = __CLPK_integer(work[0])
//        work = [Float](repeating:0, count:Int(lwork))
//        sgels_(&trans, &m, &n, &nrhs, &a_lapack, &lda, &b_lapack, &ldb, &work, &lwork, &info)
//        return info == 0 ? Array(b_lapack.prefix(numCoeffs)) : nil
//    }
//}
