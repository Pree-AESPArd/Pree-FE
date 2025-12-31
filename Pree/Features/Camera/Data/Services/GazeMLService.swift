//
//  GazeMLService.swift
//  Pree
//
//  Created by KimDogyung on 12/31/25.
//

import ARKit
import CoreML

final class GazeMLService {
    
    private var trainingData: [MLFeatureProvider] = []
    private var personalizedModel: MLModel?
    
    // 컴파일된 모델 경로
    private var modelURL: URL? {
        return Bundle.main.url(forResource: "GazeRegressor", withExtension: "mlmodelc")
    }
    
    // 학습된 모델 저장 경로
    private var savedModelURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("PersonalizedGaze.mlmodelc")
    }
    
    init() {
        // 이전에 학습된 모델이 있으면 로드
        if FileManager.default.fileExists(atPath: savedModelURL.path) {
            self.personalizedModel = try? MLModel(contentsOf: savedModelURL)
            print("💾 저장된 개인화 모델 로드 완료")
        }
    }
    
    // MARK: - 1. 데이터 수집 (캘리브레이션 중)
    func collectData(faceAnchor: ARFaceAnchor, targetPoint: CGPoint, viewSize: CGSize) {
        let features = makeFeatureVector(faceAnchor: faceAnchor)
        
        // 정답 데이터 정규화 (0.0 ~ 1.0)
        let normalizedX = Double(targetPoint.x / viewSize.width)
        let normalizedY = Double(targetPoint.y / viewSize.height)
        
        // try?를 사용하여 오버헤드 방지
        guard let inputObj = try? MLMultiArray(shape: [12], dataType: .double),
              let targetObj = try? MLMultiArray(shape: [2], dataType: .double) else { return }
        
        for (i, v) in features.enumerated() { inputObj[i] = NSNumber(value: v) }
        targetObj[0] = NSNumber(value: normalizedX)
        targetObj[1] = NSNumber(value: normalizedY)
        
        if let dataPoint = try? MLDictionaryFeatureProvider(dictionary: [
            "inputVector": inputObj,
            "targetCoordinates": targetObj
        ]) {
            trainingData.append(dataPoint)
        }
    }
    
    // MARK: - 2. 학습 (캘리브레이션 종료 후)
    func trainModel(completion: @escaping (Bool) -> Void) {
        guard let url = modelURL else { completion(false); return }
        
        let batch = MLArrayBatchProvider(array: trainingData)
        
        do {
            let task = try MLUpdateTask(forModelAt: url, trainingData: batch, configuration: nil) { context in
                // context.model은 옵셔널이 아님
                let model = context.model
                self.personalizedModel = model
                try? model.write(to: self.savedModelURL)
                
                self.trainingData.removeAll() // 데이터 비우기
                completion(true)
            }
            task.resume()
        } catch {
            print("❌ 학습 실패: \(error)")
            completion(false)
        }
    }
    
    // MARK: - 3. 예측 (실시간) - 백그라운드에서 호출 권장
    func predict(faceAnchor: ARFaceAnchor, viewSize: CGSize) -> CGPoint? {
        guard let model = personalizedModel else { return nil }
        
        let features = makeFeatureVector(faceAnchor: faceAnchor)
        
        // MLMultiArray 생성 오버헤드 최소화
        guard let inputObj = try? MLMultiArray(shape: [12], dataType: .double) else { return nil }
        
        for (i, v) in features.enumerated() { inputObj[i] = NSNumber(value: v) }
        
        guard let inputProvider = try? MLDictionaryFeatureProvider(dictionary: ["inputVector": inputObj]),
              let output = try? model.prediction(from: inputProvider),
              let result = output.featureValue(for: "targetCoordinates")?.multiArrayValue else {
            return nil
        }
        
        // 0~1 결과를 화면 좌표로 복원
        let x = CGFloat(result[0].doubleValue) * viewSize.width
        let y = CGFloat(result[1].doubleValue) * viewSize.height
        
        return CGPoint(x: x, y: y)
    }
    
    // 입력 벡터 생성 (12개: 머리위치3 + 머리회전3 + 왼눈3 + 오른눈3)
    private func makeFeatureVector(faceAnchor: ARFaceAnchor) -> [Double] {
        let t = faceAnchor.transform
        let headPos = [Double(t.columns.3.x), Double(t.columns.3.y), Double(t.columns.3.z)]
        
        // 회전 (LookAt 벡터로 근사)
        let lookAt = SIMD3<Double>(Double(-t.columns.2.x), Double(-t.columns.2.y), Double(-t.columns.2.z))
        let headRot = [lookAt.x, lookAt.y, lookAt.z]
        
        let lTrans = faceAnchor.leftEyeTransform
        let lVec = [Double(lTrans.columns.2.x), Double(lTrans.columns.2.y), Double(lTrans.columns.2.z)]
        
        let rTrans = faceAnchor.rightEyeTransform
        let rVec = [Double(rTrans.columns.2.x), Double(rTrans.columns.2.y), Double(rTrans.columns.2.z)]
        
        return headPos + headRot + lVec + rVec
    }
}
