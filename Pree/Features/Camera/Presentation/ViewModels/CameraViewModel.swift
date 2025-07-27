//
//  CameraViewModel.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI
import ReplayKit


final class CameraViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var showPreview  = false
    var previewController: RPPreviewViewController?

    private let startUseCase: StartScreenRecordingUseCase
    private let stopUseCase: StopScreenRecordingUseCase

    init(start: StartScreenRecordingUseCase,
         stop: StopScreenRecordingUseCase) {
        self.startUseCase = start
        self.stopUseCase  = stop
    }

    func toggleRecording() {
        if isRecording {
            stopUseCase.execute { result in
                switch result {
                case .success(let preview):
                    self.previewController = preview
                    self.showPreview = true
                    self.isRecording = false
                case .failure:
                    self.isRecording = false
                }
            }
        } else {
            startUseCase.execute { result in
                if case .success = result {
                    self.isRecording = true
                }
            }
        }
    }
}
