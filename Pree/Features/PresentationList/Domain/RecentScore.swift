//
//  RecentScore.swift
//  Pree
//
//  Created by KimDogyung on 1/27/26.
//

import Foundation

struct RecentScore: Codable, Identifiable {
    let takeId: UUID
    let takeNumber: Int
    let score: Double
    let createdAt: String
    
    var id: UUID { takeId }
    
    enum CodingKeys: String, CodingKey {
        case takeId = "take_id"
        case takeNumber = "take_number"
        case score = "total_score"
        case createdAt = "created_at"
    }
}
