//
//  StartScreenRecordingUseCase.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//


public final class StartScreenRecordingUseCase {
    private let service: ScreenRecordingService
    public init(service: ScreenRecordingService) {
        self.service = service
    }
    public func execute(completion: @escaping (Result<Void, ScreenRecordingError>) -> Void) {
        service.startRecording(completion: completion)
    }
}
