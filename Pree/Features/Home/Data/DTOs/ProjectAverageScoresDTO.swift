//
//  ProjectAverageScoresDTO.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

import Foundation

struct ProjectAverageScoresDTO: Codable {
    let projectId: String // UUID는 String으로 받는 것이 일반적입니다.
    let projectTitle: String
    let takeCount: Int
    
    let wpmScore: Int
    let dbScore: Int
    let fillerScore: Int
    let silenceScore: Int
    let durationScore: Int
    let eyeTrackingScore: Int
    let totalScore: Int
    
    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case projectTitle = "project_title"
        case takeCount = "take_count"
        case wpmScore = "wpm_score"
        case dbScore = "db_score"
        case fillerScore = "filler_score"
        case silenceScore = "silence_score"
        case durationScore = "duration_score"
        case eyeTrackingScore = "eye_tracking_score"
        case totalScore = "total_score"
    }
    
    // Domain Entity로 변환
    func toDomain() -> ProjectAverageScores {
        return ProjectAverageScores(
            projectId: UUID(uuidString: self.projectId) ?? UUID(),
            projectTitle: self.projectTitle,
            takeCount: self.takeCount,
            wpmScore: Int(self.wpmScore),           // 필요시 여기서 반올림(round) 처리 가능
            dbScore: Int(self.dbScore),
            fillerScore: Int(self.fillerScore),
            silenceScore: Int(self.silenceScore),
            durationScore: Int(self.durationScore),
            eyeTrackingScore: Int(self.eyeTrackingScore),
            totalScore: Int(self.totalScore)
        )
    }
}
