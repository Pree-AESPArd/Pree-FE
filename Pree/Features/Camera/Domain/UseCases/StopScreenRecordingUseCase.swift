//
//  StopScreenRecordingUseCase.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import ReplayKit

public final class StopScreenRecordingUseCase {
    private let service: ScreenRecordingService
    public init(service: ScreenRecordingService) {
        self.service = service
    }
    public func execute(completion: @escaping (Result<RPPreviewViewController, ScreenRecordingError>) -> Void) {
        service.stopRecording(completion: completion)
    }
}
