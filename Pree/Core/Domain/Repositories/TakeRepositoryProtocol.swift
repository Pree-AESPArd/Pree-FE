//
//  TakeRepositoryProtocol.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//


import Foundation

protocol TakeRepositoryProtocol {
    func uploadPractice(presentationId: String, videoKey: String, eyeTrackingRate: Int, audioURL: URL) async throws
    func fetchRecentScores(presentationId: String) async throws -> [RecentScore]
}
