//
//  ScreenRecordingService.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import ReplayKit
import AVFoundation
import Foundation

public enum ScreenCaptureError: Error {
    case noPermission
    case configurationFailed
    case notRecording
    case unknown(Error)
}

/// 화면 녹화 비즈니스 로직(UseCase)에서 의존할 추상화 인터페이스
public protocol ScreenCaptureService{
    /// 캡처를 시작해서 CMSampleBuffer를 줄 때마다 handler 호출
    func startCapture(
//        handler: @escaping (CMSampleBuffer, RPSampleBufferType) -> Void,
        completion: @escaping (Result<Void, ScreenCaptureError>) -> Void
    )
    
    /// 캡처를 중지하고, 최종 mp4 파일 URL 을 반환
    func stopCapture(
        completion: @escaping (Result<URL, ScreenCaptureError>) -> Void
    )
}
