//
//  ScreenRecordingService.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import ReplayKit
import UIKit

public enum ScreenRecordingError: Error {
    case noPermission, alreadyRecording, notRecording, unknown
}

/// 화면 녹화 비즈니스 로직(UseCase)에서 의존할 추상화 인터페이스
public protocol ScreenRecordingService {
    func startRecording(completion: @escaping (Result<Void, ScreenRecordingError>) -> Void)
    func stopRecording(completion: @escaping (Result<RPPreviewViewController, ScreenRecordingError>) -> Void)
}
