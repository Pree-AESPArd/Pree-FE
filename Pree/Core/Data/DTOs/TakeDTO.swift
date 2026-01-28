//
//  TakeDTO.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//

import Foundation

struct TakeDTO: Codable {
    let id: String
    let projectId: String
    let takeNumber: Int
    let videoKey: String
    let audioUrl: String
    let status: TakeStatus
    let eyeTrackingScore: Int
    let totalScore: Int
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case projectId = "project_id"
        case takeNumber = "take_number"
        case videoKey = "video_key"
        case audioUrl = "audio_url"
        case status
        case eyeTrackingScore = "eye_tracking_score"
        case totalScore = "total_score"
        case createdAt = "created_at"
    }
    
    // DTO -> Domain Entity 변환 메서드
    func toDomain() -> Take {
        // ISO8601 날짜 파싱
        let isoFormatter = ISO8601DateFormatter()
        // 소수점 초(.129Z) 처리를 위한 옵션 설정
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        let date = isoFormatter.date(from: self.createdAt) ?? Date()
        
        return Take(
            id: self.id,
            presentationId: self.projectId,
            takeNumber: self.takeNumber,
            videoKey: self.videoKey,
            audioURL: self.audioUrl,
            status: self.status,
            eyeTrackingScore: self.eyeTrackingScore,
            totalScore: self.totalScore,
            createdAt: date
        )
    }
}
