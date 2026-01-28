//
//  ProjectAverageScores.swift
//  Pree
//
//  Created by KimDogyung on 1/28/26.
//

import Foundation

struct ProjectAverageScores: Identifiable, Hashable {
    let id = UUID()
    let projectId: UUID
    let projectTitle: String
    let takeCount: Int
    
    let wpmScore: Int
    let dbScore: Int
    let fillerScore: Int
    let silenceScore: Int
    let durationScore: Int
    let eyeTrackingScore: Int
    let totalScore: Int
}
