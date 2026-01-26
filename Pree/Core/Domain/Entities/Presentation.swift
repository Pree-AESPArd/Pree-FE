//
//  Presentation.swift
//  Pree
//
//  Created by KimDogyung on 8/21/25.
//

import Foundation

struct Presentation: Codable, Equatable,Hashable {
    let id: String
    let presentationName: String
    let idealMinTime: Double
    let idealMaxTime: Double
    let showTimeOnScreen: Bool
    let showMeOnScreen: Bool
    let isDevMode: Bool
    
    let totalScore: Int?
    let totalPractices: Int
    let isFavorite: Bool
    let updatedAtText: String
    let createdAt: String
    let updatedAt: String
    
}


extension Presentation {
    
    func updateFavorite(_ isFavorite: Bool) -> Presentation {
        return Presentation(
            id: self.id,
            presentationName: self.presentationName,
            idealMinTime: self.idealMinTime,
            idealMaxTime: self.idealMaxTime,
            showTimeOnScreen: self.showTimeOnScreen,
            showMeOnScreen: self.showMeOnScreen,
            isDevMode: self.isDevMode,
            totalScore: self.totalScore,
            totalPractices: self.totalPractices,
            isFavorite: isFavorite, // 여기만 변경됨
            updatedAtText: self.updatedAtText,
            createdAt: self.createdAt,
            updatedAt: self.updatedAt
        )
    }
    
    static func mockList() -> [Presentation] {
        return [
            Presentation(
                id: "id-001",
                presentationName: "클린 아키텍처 소개",
                idealMinTime: 10.0,
                idealMaxTime: 15.0,
                showTimeOnScreen: true,
                showMeOnScreen: true,
                isDevMode: true,
                totalScore: 95,
                totalPractices: 5,
                isFavorite: false,
                updatedAtText: "3",
                createdAt: "2025-09-01T10:00:00Z",
                updatedAt: "2025-09-01T10:00:00Z"
            ),
            Presentation(
                id: "id-002",
                presentationName: "SwiftUI 테스트 전략",
                idealMinTime: 8.0,
                idealMaxTime: 12.0,
                showTimeOnScreen: false,
                showMeOnScreen: true,
                isDevMode: true,
                totalScore: 88,
                totalPractices: 2,
                isFavorite: false,
                updatedAtText: "1",
                createdAt: "2025-08-25T15:30:00Z",
                updatedAt: "2025-08-25T15:30:00Z"
            )
        ]
    }
    
}
