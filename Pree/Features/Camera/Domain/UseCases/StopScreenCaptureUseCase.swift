//
//  StopScreenRecordingUseCase.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import ReplayKit
import Foundation

struct StopScreenCaptureUseCase: StopScreenCaptureUseCaseProtocol {
  private let service: ScreenCaptureService

  public init(service: ScreenCaptureService) {
    self.service = service
  }

  public func execute(
    completion: @escaping (Result<URL, ScreenCaptureError>) -> Void
  ) {
    service.stopCapture(completion: completion)
  }
}
