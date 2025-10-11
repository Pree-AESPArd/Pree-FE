//
//  MockStopScreenCaptureUseCase.swift
//  Pree
//
//  Created by KimDogyung on 10/11/25.
//

import Foundation
import Combine
import RealityKit
@testable import Pree // @testable을 사용해 internal 타입에 접근


final class MockStopScreenCaptureUseCase: StopScreenCaptureUseCaseProtocol {
    var executeCalled = false
    var shouldSucceed = true
    
    func execute(completion: @escaping (Result<URL, ScreenCaptureError>) -> Void) {
        executeCalled = true
        if shouldSucceed {
            completion(.success(URL(string: "file:///mock_video.mov")!))
        } else {
            completion(.failure(.unknown(NSError(domain: "MockError", code: 1)))) 
        }
    }
}
