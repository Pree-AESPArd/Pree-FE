//
//  UploadPracticeUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 11/22/25.
//

protocol UploadPracticeUseCaseProtocol {
    func execute(mode: PracticeMode, videoKey: String, eyePercentage: Int) async throws
}
