//
//  Take.swift
//  Pree
//
//  Created by KimDogyung on 1/27/26.
//

import Foundation

struct Take: Codable {
    var id: Int
    var projectId: String
    var takeNumber: Int
    var practiceName: String
    var createdAt: String
    var totalScore: Int
    var analysisId: Int
    var videoKey: String
}
