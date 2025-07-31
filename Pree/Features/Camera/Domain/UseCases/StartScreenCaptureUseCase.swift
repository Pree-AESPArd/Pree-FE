//
//  StartScreenRecordingUseCase.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//


import Foundation
import AVFoundation
import ReplayKit

public final class StartScreenCaptureUseCase {
  private let service: ScreenCaptureService

  public init(service: ScreenCaptureService) {
    self.service = service
  }

  public func execute(
//    handler: @escaping (CMSampleBuffer, RPSampleBufferType) -> Void,
    completion: @escaping (Result<Void, ScreenCaptureError>) -> Void
  ) {
    service.startCapture(completion: completion)
  }
}
