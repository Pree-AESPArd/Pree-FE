//
//  Presentation.swift
//  Pree
//
//  Created by KimDogyung on 8/21/25.
//

import Foundation

struct Presentation: Codable {
    let presentationId: String?
    let presentationName: String
    let idealMinTime: Double
    let idealMaxTime: Double
    let showTimeOnScreen: Bool
    let showMeOnScreen: Bool
    
    let totalScore: Int
    let totalPractices: Int
    let createdAt: String?
    let updatedAt: String?
}
