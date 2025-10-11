//
//  MockStartScreenCaptureUseCase.swift
//  Pree
//
//  Created by KimDogyung on 10/11/25.
//

import Foundation
import Combine
import RealityKit
@testable import Pree // @testable을 사용해 internal 타입에 접근

final class MockStartScreenCaptureUseCase: StartScreenCaptureUseCaseProtocol {
    var executeCalled = false
    var shouldSucceed = true

    func execute(completion: @escaping (Result<Void, ScreenCaptureError>) -> Void) {
        executeCalled = true
        if shouldSucceed {
            completion(.success(()))
        } else {
            completion(.failure(.unknown(NSError(domain: "MockError", code: 1)))) 
        }
    }
}
