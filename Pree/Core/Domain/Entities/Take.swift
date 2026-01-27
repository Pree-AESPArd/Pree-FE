//
//  Take.swift
//  Pree
//
//  Created by KimDogyung on 1/27/26.
//

import Foundation

import Foundation

struct Take: Identifiable, Hashable {
    let id: String
    let presentationId: String
    let takeNumber: Int
    let videoKey: String
    let audioURL: String?
    let status: TakeStatus
    let eyeTrackingScore: Int
    let totalScore: Int
    let createdAt: Date
    
    // 날짜 포맷팅을 위한 연산 프로퍼티
    var dateText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter.string(from: createdAt)
    }
}
