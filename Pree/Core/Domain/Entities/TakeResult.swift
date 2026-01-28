//
//  TakeResult.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

import Foundation

// 1. 전체 결과를 담는 Root Entity
struct TakeResult: Identifiable {
    let id: String // take_info의 id를 식별자로 사용
    let takeInfo: Take
    let analysis: Analysis
}

// 2. 분석 정보를 담는 Entity
struct Analysis: Hashable {
    let rawText: String
    
    let wpm: Int
    let decibelAvg: Int
    let silenceRatio: Int
    let fillerWordCount: Int
    
    let wpmScore: Int
    let dbScore: Int
    let fillerScore: Int
    let silenceScore: Int
    let durationScore: Int
    let eyeTrackingScore: Int
    let totalScore: Int
}
