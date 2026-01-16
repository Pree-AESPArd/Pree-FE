//
//  MediaServiceProtocol.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//

import Foundation

protocol MediaServiceProtocol {
    func saveVideoToGallery(url: URL) async throws -> String
    func extractAudio(from videoURL: URL) async throws -> URL
}
