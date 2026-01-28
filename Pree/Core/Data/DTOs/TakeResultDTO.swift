//
//  TakeResult.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

import Foundation

struct TakeResultDTO: Codable {
    let takeInfo: TakeDTO
    let analysis: AnalysisDTO
    
    enum CodingKeys: String, CodingKey {
        case takeInfo = "take_info"
        case analysis
    }
    
    func toDomain() -> TakeResult {
        return TakeResult(
            id: takeInfo.id,
            takeInfo: takeInfo.toDomain(),
            analysis: analysis.toDomain()
        )
    }
}

// 2. 분석 정보 DTO
struct AnalysisDTO: Codable {
    let rawText: String
    let wpm: Int
    let wpmScore: Int
    let decibelAvg: Int
    let dbScore: Int
    let fillerWordCount: Int
    let fillerScore: Int
    let silenceRatio: Int
    let silenceScore: Int
    let durationScore: Int
    let eyeTrackingScore: Int
    let totalScore: Int
    
    enum CodingKeys: String, CodingKey {
        case rawText = "raw_text"
        case wpm
        case wpmScore = "wpm_score"
        case decibelAvg = "decibel_avg"
        case dbScore = "db_score"
        case fillerWordCount = "filler_word_count"
        case fillerScore = "filler_score"
        case silenceRatio = "silence_ratio"
        case silenceScore = "silence_score"
        case durationScore = "duration_score"
        case eyeTrackingScore = "eye_tracking_score"
        case totalScore = "total_score"
    }
    
    func toDomain() -> Analysis {
        return Analysis(
            rawText: self.rawText,
            wpm: self.wpm,
            decibelAvg: self.decibelAvg,
            silenceRatio: self.silenceRatio,
            fillerWordCount: self.fillerWordCount,
            wpmScore: self.wpmScore,
            dbScore: self.dbScore,
            fillerScore: self.fillerScore,
            silenceScore: self.silenceScore,
            durationScore: self.durationScore,
            eyeTrackingScore: self.eyeTrackingScore,
            totalScore: self.totalScore
        )
    }
}
