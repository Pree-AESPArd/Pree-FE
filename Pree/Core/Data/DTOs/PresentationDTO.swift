//
//  PresentationDTO.swift
//  Pree
//
//  Created by KimDogyung on 1/8/26.
//

import Foundation

struct PresentationDTO: Codable, Identifiable {
    var id: String { presentationId ?? UUID().uuidString }
    
    let presentationId: String?
    let presentationName: String
    let idealMinTime: Double
    let idealMaxTime: Double
    let showTimeOnScreen: Bool
    let showMeOnScreen: Bool
    let isDevMode: Bool

    let totalScore: Int
    let totalPractices: Int
    let toggleFavorite: Bool
    let createdAt: String?
    let updatedAt: String?
    
    // 서버에서 오는 JSON 키값과 매칭
    enum CodingKeys: String, CodingKey {
        case presentationId = "id"
        case presentationName = "title"
        case idealMinTime = "min_duration"
        case idealMaxTime = "max_duration"
        case showTimeOnScreen = "show_timer"
        case showMeOnScreen = "show_camera"
        case isDevMode = "is_dev_mode"
        
        case totalScore = "total_score"
        case totalPractices = "take_count"
        case toggleFavorite = "is_favorite"
        case createdAt = "created_at"
        case updatedAt = "last_take_at"
    }
}


//extension PresentationDTO {
//        
//    static func mockList() -> [PresentationDTO] {
//        return [
//            PresentationDTO(
//                presentationId: "id-001",
//                presentationName: "클린 아키텍처 소개",
//                idealMinTime: 10.0,
//                idealMaxTime: 15.0,
//                showTimeOnScreen: true,
//                showMeOnScreen: true,
//                totalScore: 95,
//                totalPractices: 5,
//                toggleFavorite: false,
//                updatedAtText: "3",
//                createdAt: "2025-09-01T10:00:00Z",
//                updatedAt: "2025-09-01T10:00:00Z"
//            ),
//            PresentationDTO(
//                presentationId: "id-002",
//                presentationName: "SwiftUI 테스트 전략",
//                idealMinTime: 8.0,
//                idealMaxTime: 12.0,
//                showTimeOnScreen: false,
//                showMeOnScreen: true,
//                totalScore: 88,
//                totalPractices: 2,
//                toggleFavorite: false,
//                updatedAtText: "1",
//                createdAt: "2025-08-25T15:30:00Z",
//                updatedAt: "2025-08-25T15:30:00Z"
//            )
//        ]
//    }
//    
//}
