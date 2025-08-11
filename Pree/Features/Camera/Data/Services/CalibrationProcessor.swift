//// CalibrationProcessor.swift
//
//import Foundation
//import CoreGraphics
//import Accelerate
//
///// 하이브리드 캘리브레이션 모델을 생성하는 최종 처리기
//struct CalibrationProcessor {
//    
//    fileprivate struct Edge: Hashable { let i, j: Int }
//
//    enum CalibrationError: Error {
//        case notEnoughDataPoints, processingFailed, insufficientCleanData, triangulationFailed
//    }
//
//    func calculate(targets: [CGPoint], samples: [[CGPoint]]) -> Result<GazeMapper, CalibrationError> {
//        var cleanedRaws: [CGPoint] = [], validTargets: [CGPoint] = []
//        for (index, pointArray) in samples.enumerated() {
//            guard pointArray.count >= 10, let center = robustCenter(of: pointArray) else { continue }
//            cleanedRaws.append(center)
//            validTargets.append(targets[index])
//        }
//        guard validTargets.count >= 6 else { return .failure(.insufficientCleanData) }
//
//        guard let piecewiseModel = createPiecewiseModel(raws: cleanedRaws, targets: validTargets) else {
//            return .failure(.triangulationFailed)
//        }
//
//        var residuals: [CGPoint] = []
//        for i in 0..<cleanedRaws.count {
//            let primaryCorrectedPoint = piecewiseModel.calibratedPoint(for: cleanedRaws[i])
//            residuals.append(CGPoint(x: validTargets[i].x - primaryCorrectedPoint.x,
//                                     y: validTargets[i].y - primaryCorrectedPoint.y))
//        }
//
//        guard let residualPolynomial = createPolynomialModel(raws: cleanedRaws, targets: residuals) else {
//            return .failure(.processingFailed)
//        }
//        
//        let hybridModel = HybridCalibration(piecewiseModel: piecewiseModel, residualPolynomial: residualPolynomial)
//        return .success(hybridModel)
//    }
//
//    // MARK: - Private Model Creation Helpers
//    private func createPiecewiseModel(raws: [CGPoint], targets: [CGPoint]) -> PiecewiseCalibration? {
//        let triangles = triangulate(points: raws)
//        guard !triangles.isEmpty else { return nil }
//        var rawTriangles: [(p1: CGPoint, p2: CGPoint, p3: CGPoint)] = [], transforms: [AffineTransform] = []
//        for t in triangles {
//            let rp = (raws[t.i], raws[t.j], raws[t.k]); let tp = (targets[t.i], targets[t.j], targets[t.k])
//            if let trans = AffineTransform(raw: rp, target: tp) {
//                rawTriangles.append(rp); transforms.append(trans)
//            }
//        }
//        return PiecewiseCalibration(rawTriangles: rawTriangles, transforms: transforms)
//    }
//    
//    private func createPolynomialModel(raws: [CGPoint], targets: [CGPoint]) -> GazePolynomial? {
//        let numCoeffs = 6
//        guard raws.count >= numCoeffs else { return nil }
//        let rawX = raws.map{Float($0.x)}, rawY = raws.map{Float($0.y)}
//        guard let minX = rawX.min(), let maxX = rawX.max(), let minY = rawY.min(), let maxY = rawY.max(), (maxX - minX) > 0.1, (maxY - minY) > 0.1 else { return nil }
//        let normRaws = raws.map{(x:2*Float($0.x-minX)/(maxX-minX)-1, y:2*Float($0.y-minY)/(maxY-minY)-1)}
//        var a = [Float](repeating:0, count:raws.count*numCoeffs), bX = targets.map{Float($0.x)}, bY = targets.map{Float($0.y)}
//        for (i, p) in normRaws.enumerated() {
//            let r=i*numCoeffs; a[r+0]=1; a[r+1]=p.x; a[r+2]=p.y; a[r+3]=p.x*p.y; a[r+4]=p.x*p.x; a[r+5]=p.y*p.y
//        }
//        guard let xC = solve(a:a,b:bX,nS:raws.count,nC:numCoeffs), let yC = solve(a:a,b:bY,nS:raws.count,nC:numCoeffs) else {return nil}
//        let nP = GazePolynomial.NormalizationParameters(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
//        return GazePolynomial(xCoefficients: xC, yCoefficients: yC, normalization: nP)
//    }
//
//    // MARK: - Low-Level Algorithms
//    private func robustCenter(of pts: [CGPoint], k: CGFloat = 2.8) -> CGPoint? {
//        if pts.isEmpty { return nil }; if pts.count < 3 { return mean(of: pts) }
//        let xs = pts.map{$0.x}, ys = pts.map{$0.y}; let mx = median(xs), my = median(ys)
//        let madX = median(xs.map{abs($0-mx)}), madY = median(ys.map{abs($0-my)})
//        let c:CGFloat=1.4826, eps:CGFloat=1.0; let thrX=k*c*(madX==0 ? eps:madX), thrY=k*c*(madY==0 ? eps:madY)
//        let filtered = pts.filter{abs($0.x-mx)<=thrX && abs($0.y-my)<=thrY}
//        return filtered.isEmpty ? CGPoint(x:mx, y:my) : mean(of: filtered)
//    }
//    
//    private func triangulate(points: [CGPoint]) -> [Triangle] {
//        if points.count < 3 { return [] }; var tris: [Triangle] = []; let n = points.count; var all = points
//        let st = createSuperTriangle(points: points); all.append(contentsOf: [st.0, st.1, st.2])
//        tris.append(Triangle(i: n, j: n + 1, k: n + 2))
//        for i in 0..<n {
//            var edges: [Edge] = [], badI: [Int] = []
//            for (ti, t) in tris.enumerated() {
//                if isInCircumcircle(p: all[i], t: (all[t.i], all[t.j], all[t.k])) {
//                    badI.append(ti); edges.append(contentsOf: [Edge(i:t.i,j:t.j), Edge(i:t.j,j:t.k), Edge(i:t.k,j:t.i)])
//                }
//            }
//            for index in badI.sorted(by: >) { tris.remove(at: index) }
//            var uniqueE: [Edge] = []; var eC: [Edge:Int]=[:]; for e in edges {let s=Edge(i:min(e.i,e.j),j:max(e.i,e.j));eC[s,default:0]+=1}; uniqueE=eC.filter{$0.value==1}.map{$0.key}
//            for edge in uniqueE { tris.append(Triangle(i: edge.i, j: edge.j, k: i)) }
//        }
//        tris.removeAll { $0.i >= n || $0.j >= n || $0.k >= n }
//        return tris
//    }
//
//    private func solve(a: [Float], b: [Float], nS: Int, nC: Int) -> [Float]? {
//        var a_l=a, b_l=b; var t=CChar("N".utf8.first!); var m=__CLPK_integer(nS), n=__CLPK_integer(nC)
//        var nrhs:__CLPK_integer=1, lda:__CLPK_integer=m, ldb:__CLPK_integer=m, info:__CLPK_integer=0, lw:__CLPK_integer = -1
//        var w=[Float](repeating:0,count:1); sgels_(&t,&m,&n,&nrhs,&a_l,&lda,&b_l,&ldb,&w,&lw,&info)
//        lw=__CLPK_integer(w[0]); w=[Float](repeating:0,count:Int(lw))
//        sgels_(&t,&m,&n,&nrhs,&a_l,&lda,&b_l,&ldb,&w,&lw,&info)
//        return info==0 ? Array(b_l.prefix(nC)) : nil
//    }
//    
//    private func mean(of points:[CGPoint])->CGPoint?{if points.isEmpty{return nil};let sX=points.reduce(0,{$0+$1.x}),sY=points.reduce(0,{$0+$1.y});return CGPoint(x:sX/CGFloat(points.count),y:sY/CGFloat(points.count))}
//    private func median(_ xs:[CGFloat])->CGFloat{if xs.isEmpty{return 0};let s=xs.sorted(),m=s.count/2;return s.count%2==0 ? (s[m-1]+s[m])/2:s[m]}
//    private func createSuperTriangle(points:[CGPoint])->(CGPoint,CGPoint,CGPoint){var minX=points[0].x,minY=points[0].y,maxX=minX,maxY=minY;for i in 1..<points.count{minX=min(minX,points[i].x);maxX=max(maxX,points[i].x);minY=min(minY,points[i].y);maxY=max(maxY,points[i].y)};let dx=maxX-minX,dy=maxY-minY,dm=max(dx,dy),mx=(minX+maxX)/2,my=(minY+maxY)/2;return(CGPoint(x:mx-20*dm,y:my-dm),CGPoint(x:mx,y:my+20*dm),CGPoint(x:mx+20*dm,y:my-dm))}
//    private func isInCircumcircle(p:CGPoint,t:(p1:CGPoint,p2:CGPoint,p3:CGPoint))->Bool{let(p1,p2,p3)=t;let d=2*(p1.x*(p2.y-p3.y)+p2.x*(p3.y-p1.y)+p3.x*(p1.y-p2.y));if abs(d)<1e-9{return false};let p1s=p1.x*p1.x+p1.y*p1.y,p2s=p2.x*p2.x+p2.y*p2.y,p3s=p3.x*p3.x+p3.y*p3.y;let cx=(p1s*(p2.y-p3.y)+p2s*(p3.y-p1.y)+p3s*(p1.y-p2.y))/d;let cy=(p1s*(p3.x-p2.x)+p2s*(p1.x-p3.x)+p3s*(p2.x-p1.x))/d;let r2=(p1.x-cx)*(p1.x-cx)+(p1.y-cy)*(p1.y-cy);let ds=(p.x-cx)*(p.x-cx)+(p.y-cy)*(p.y-cy);return ds<r2}
//}
