//
//  ScreenCaptureServiceImpl.swift
//  Pree
//
//  Created by KimDogyung on 7/28/25.
//

import Foundation
import ReplayKit
import AVFoundation
import AVFAudio
import UIKit
import Photos

public final class ScreenCaptureServiceImpl: ScreenCaptureService {
    private let recorder = RPScreenRecorder.shared()
    private var assetWriter: AVAssetWriter?
    private var videoInput: AVAssetWriterInput?
    private var audioInput: AVAssetWriterInput?
    

    /// ``ReplayKitDispatchQueue``
    // 요약: 큐를 써야지 순서대로 로직이 담겨서 실행이 되고 .video와 .audioMic 가 충돌 안남
    let writeQueue = DispatchQueue(label: "com.pree.screenCapture.writer")
    
    // 세션 시작 여부를 추적하는 플래그
    private var isSessionStarted = false
    
    // 임시 파일 URL
    private lazy var outputURL: URL = {
        let tmp = FileManager.default.temporaryDirectory
            .appendingPathComponent("pree_\(UUID().uuidString).mp4")
        // 기존 파일이 있다면 삭제
        try? FileManager.default.removeItem(at: tmp)
        return tmp
    }()
    
    public init() {}
    
    
    
    public func startCapture(
        completion: @escaping (Result<Void, ScreenCaptureError>) -> Void
    ) {
        // 1) Writer 셋업
        do {
            try setupWriter()
        } catch {
            completion(.failure(.configurationFailed))
            return
        }
        
        // 2) AVAudioSession 구성 & 활성화
        // 이거 안하면 오디오 녹음이 안됨
        let audioSession = AVAudioSession.sharedInstance()
        do {
            // .playAndRecord 로 해야 mic 입력이 ReplayKit 에 제대로 전달됩니다.
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [])
            try audioSession.setActive(true)
        } catch {
            completion(.failure(.configurationFailed))
            return
        }
        
        // 3) mic 권한 요청 (허용된 뒤에 capture 시작)
        // iOS 17 이상: AVAudioApplication으로 권한 요청
        if #available(iOS 17.0, *) {
            let audioApp = AVAudioApplication.shared
            switch audioApp.recordPermission {
            case .undetermined:
                AVAudioApplication.requestRecordPermission { granted in
                    guard granted else {
                        completion(.failure(.noPermission))
                        return
                    }
                    // 실제로 녹화 시작
                    self.startReplayKit(completion: completion)
                }
            case .denied:
                completion(.failure(.noPermission))
            case .granted:
                // 실제로 녹화 시작
                startReplayKit(completion: completion)
            @unknown default:
                completion(.failure(.noPermission))
            }
        } else {
            // iOS 16 이하: 기존 API 사용
            switch audioSession.recordPermission {
            case .undetermined:
                audioSession.requestRecordPermission { granted in
                    guard granted else {
                        completion(.failure(.noPermission))
                        return
                    }
                    // 실제로 녹화 시작
                    self.startReplayKit(completion: completion)
                }
            case .denied:
                completion(.failure(.noPermission))
            case .granted:
                // 실제로 녹화 시작
                startReplayKit(completion: completion)
            @unknown default:
                completion(.failure(.noPermission))
            }
        }
    }
    
    // MARK: - ReplayKit 실제 시작을 분리
    private func startReplayKit(completion: @escaping (Result<Void, ScreenCaptureError>) -> Void) {
        recorder.isMicrophoneEnabled = true
        recorder.startCapture(handler: { [weak self] sampleBuffer, bufferType, error in
            guard let self = self else { return }
            self.writeQueue.sync {
                if let err = error {
                    self.stopCapture { _ in }
                    return
                }
                // 오직 video + audioMic
                guard bufferType == .video || bufferType == .audioMic else { return }
                
                if !self.isSessionStarted {
                    self.assetWriter?.startWriting()
                    let ts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer)
                    self.assetWriter?.startSession(atSourceTime: ts)
                    self.isSessionStarted = true
                }
                if bufferType == .video, self.videoInput?.isReadyForMoreMediaData == true {
                    self.videoInput?.append(sampleBuffer)
                } else if bufferType == .audioMic, self.audioInput?.isReadyForMoreMediaData == true {
                    self.audioInput?.append(sampleBuffer)
                }
            }
        }, completionHandler: { error in
            if let e = error { completion(.failure(.unknown(e))) }
            else          { completion(.success(())) }
        })
    }
    
    
    // MARK: - stopCapture
    public func stopCapture(
        completion: @escaping (Result<URL, ScreenCaptureError>) -> Void
    ) {
        
        recorder.stopCapture { [weak self] error in
            guard let self = self else { return }
            self.writeQueue.sync {
                if let e = error {
                    completion(.failure(.unknown(e)))
                    return
                }
                self.videoInput?.markAsFinished()
                self.audioInput?.markAsFinished()
                self.assetWriter?.finishWriting {
                    self.isSessionStarted = false

                    completion(.success(self.outputURL))
                }
            }
        }
        
    }
    
    // MARK: - AVAssetWriter 설정
    private func setupWriter() throws {
        assetWriter = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)
        
        // 1) 실제 화면 크기 (포인트 단위)
        let screenSize = UIScreen.main.bounds.size
        // 2) 디스플레이 스케일(2×, 3×)을 곱해서 픽셀 단위로 변환
        let width  = Int(screenSize.width * UIScreen.main.scale)
        let height = Int(screenSize.height * UIScreen.main.scale)
        
        // 비디오 설정 (1080p, H.264, 5Mbps)
        let videoSettings: [String: Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height,
            AVVideoCompressionPropertiesKey: [
                AVVideoAverageBitRateKey: 5_000_000
            ]
        ]
        let vInput = AVAssetWriterInput(mediaType: .video, outputSettings: videoSettings)
        vInput.expectsMediaDataInRealTime = true
        if assetWriter!.canAdd(vInput) { assetWriter!.add(vInput) }
        videoInput = vInput
        
        // 오디오 설정 (AAC, 48kHz, 스테레오, 128kbps)
        let audioSettings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 48_000,
            AVNumberOfChannelsKey: 2,
            AVEncoderBitRateKey: 128_000
        ]
        let aInput = AVAssetWriterInput(mediaType: .audio, outputSettings: audioSettings)
        aInput.expectsMediaDataInRealTime = true
        if assetWriter!.canAdd(aInput) { assetWriter!.add(aInput) }
        audioInput = aInput
        
    }
    
   
    // 안씀
    func saveVideoToGallery(_ videoURL: URL, completion: @escaping (Bool, Error?) -> Void) {
        // 1) 권한 요청
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(false, ScreenCaptureError.noPermission)
                return
            }
            // 2) 변경 작업 수행
            PHPhotoLibrary.shared().performChanges {
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    completion(success, error)
                }
            }
        }
    }
    
}
