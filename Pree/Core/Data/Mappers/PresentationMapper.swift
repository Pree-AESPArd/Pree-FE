//
//  PresentationMapper.swift
//  Pree
//
//  Created by KimDogyung on 1/9/26.
//

import Foundation

enum PresentationMapper {
    static func toEntity(_ dto: PresentationDTO) -> Presentation {
        Presentation(
            presentationId: dto.presentationId,
            presentationName: dto.presentationName,
            idealMinTime: dto.idealMinTime,
            idealMaxTime: dto.idealMaxTime,
            showTimeOnScreen: dto.showTimeOnScreen,
            showMeOnScreen: dto.showMeOnScreen,
            isDevMode: dto.isDevMode,
            totalScore: dto.totalScore,
            totalPractices: dto.totalPractices,
            toggleFavorite: dto.toggleFavorite,
            updatedAtText: makeUpdatedAtText(from: dto.updatedAt),
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }
    
    private static func makeUpdatedAtText(from dateString: String?) -> String? {
        guard let dateString = dateString else { return nil }
        
        // 1. 서버에서 오는 날짜 형식에 맞춰 Formatter 생성
        // (일반적인 ISO8601 형식을 가정 e.g., "2024-01-08T14:30:00Z")
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds] // 초 단위 소수점(.123)이 있을 경우 대비
        
        // 날짜 변환 시도
        guard let targetDate = isoFormatter.date(from: dateString) else {
            // 소수점이 없는 포맷일 수도 있으므로 옵션 빼고 한 번 더 시도
            isoFormatter.formatOptions = [.withInternetDateTime]
            guard let retryDate = isoFormatter.date(from: dateString) else { return nil }
            return daysBetween(start: retryDate)
        }
        
        return daysBetween(start: targetDate)
    }
    
    private static func daysBetween(start: Date) -> String {
        let calendar = Calendar.current
        let end = Date() // 현재 시간
        
        // 시간을 제외하고 '날짜'만으로 비교하기 위해 startOfDay 사용
        let startDate = calendar.startOfDay(for: start)
        let endDate = calendar.startOfDay(for: end)
        
        // 날짜 차이 계산
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        
        guard let days = components.day else { return "" }
        
        return String(days)
//        if days == 0 {
//            return "오늘"
//        } else if days == 1 {
//            return "어제"
//        } else if days > 0 {
//            return "\(days)일 전"
//        } else {
//            return "방금 전" // 미래의 시간이 들어올 경우 예외 처리
//        }
    }
}
