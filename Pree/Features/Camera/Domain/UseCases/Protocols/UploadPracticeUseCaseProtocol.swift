//
//  UploadPracticeUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 11/22/25.
//

protocol UploadPracticeUseCaseProtocol {
    func execute(videoKey: String, eyePercentage: Int) async throws
}
