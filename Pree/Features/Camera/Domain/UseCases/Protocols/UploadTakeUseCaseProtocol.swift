//
//  UploadPracticeUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 11/22/25.
//

import Foundation

protocol UploadTakeUseCaseProtocol {
    func execute(presentationId: String, videoKey: String, audioURL: URL, eyeTrackingRate: Int) async throws
}
