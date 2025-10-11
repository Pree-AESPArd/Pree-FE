//
//  StartScreenCaptureUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 10/11/25.
//

import Foundation

// StartScreenCaptureUseCase 프로토콜
public protocol StartScreenCaptureUseCaseProtocol {
    func execute(completion: @escaping (Result<Void, ScreenCaptureError>) -> Void)
}
