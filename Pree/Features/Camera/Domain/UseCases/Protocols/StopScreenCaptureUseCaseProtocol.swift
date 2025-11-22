//
//  StopScreenCaptureUseCaseProtocol.swift
//  Pree
//
//  Created by KimDogyung on 10/11/25.
//

import Foundation
import ReplayKit
import RealityKit
import Combine

protocol StopScreenCaptureUseCaseProtocol {
    func execute(completion: @escaping (Result<URL, ScreenCaptureError>) -> Void)
}
