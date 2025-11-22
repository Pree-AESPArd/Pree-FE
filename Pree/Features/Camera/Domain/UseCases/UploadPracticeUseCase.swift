//
//  UploadPracticeUseCase.swift
//  Pree
//
//  Created by KimDogyung on 11/22/25.
//

struct UploadPracticeUseCase: UploadPracticeUseCaseProtocol {
//    let repository: PracticeRepositoryProtocol
    
    func execute(mode: PracticeMode, videoKey: String, eyePercentage: Int) async throws {
        switch mode {
        case .newCreation(let userId):
            // 모델 1 생성
            let requestModel = CreatePracticeAfterCreatePresentation(
                userId: userId,
                videoKey: videoKey,
                eyePercentage: eyePercentage
            )
            // Repository의 함수 A 호출
//            try await repository.uploadNewPractice(audioURL: audioURL, request: requestModel)
            
        case .additional(let presentationId):
            // 모델 2 생성
            let requestModel = CreatePracticeRequest(
                presentationId: presentationId,
                videoKey: videoKey,
                eyePercentage: eyePercentage
            )
            // Repository의 함수 B 호출
//            try await repository.uploadExistingPractice(audioURL: audioURL, request: requestModel)
        }
    }
}
