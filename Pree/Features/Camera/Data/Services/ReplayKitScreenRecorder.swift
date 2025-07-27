//
//  ReplayKitScreenRecorder.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import ReplayKit
import UIKit


public final class ReplayKitScreenRecorder: ScreenRecordingService {
    private let recorder = RPScreenRecorder.shared()

    public init() {}

    public func startRecording(completion: @escaping (Result<Void, ScreenRecordingError>) -> Void) {
        guard !recorder.isRecording else {
            return completion(.failure(.alreadyRecording))
        }
        recorder.isMicrophoneEnabled = true
        recorder.startRecording { error in
            if let _ = error {
                completion(.failure(.unknown))
            } else {
                completion(.success(()))
            }
        }
    }

    public func stopRecording(completion: @escaping (Result<RPPreviewViewController, ScreenRecordingError>) -> Void) {
        guard recorder.isRecording else {
            return completion(.failure(.notRecording))
        }
        recorder.stopRecording { preview, error in
            if let pre = preview {
                completion(.success(pre))
            } else {
                completion(.failure(.unknown))
            }
        }
    }
}
