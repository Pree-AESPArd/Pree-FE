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
            id: dto.id,
            presentationName: dto.presentationName,
            idealMinTime: dto.idealMinTime,
            idealMaxTime: dto.idealMaxTime,
            showTimeOnScreen: dto.showTimeOnScreen,
            showMeOnScreen: dto.showMeOnScreen,
            isDevMode: dto.isDevMode,
            totalScore: dto.totalScore,
            totalPractices: dto.totalPractices,
            isFavorite: dto.isFavorite,
            updatedAtText: makeUpdatedAtText(from: dto.updatedAt),
            createdAt: dto.createdAt,
            updatedAt: dto.updatedAt
        )
    }
    
    
    private static func makeUpdatedAtText(from dateString: String) -> String {
        
        // 1. ISO8601 포맷터 생성
        let isoFormatter = ISO8601DateFormatter()
        
        // 2. 먼저 '초 단위 소수점(.123)'이 포함된 형식 시도
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let targetDate = isoFormatter.date(from: dateString) {
            return daysBetween(start: targetDate)
        }
        
        // 3. 실패 시, 소수점이 없는 일반적인 ISO8601 형식 시도
        isoFormatter.formatOptions = [.withInternetDateTime]
        
        if let retryDate = isoFormatter.date(from: dateString) {
            return daysBetween(start: retryDate)
        }
        
        // 4. 날짜 파싱에 모두 실패했을 경우 안전하게 기본값 반환
        return "날짜 알 수 없음"
    }
    
    private static func daysBetween(start: Date) -> String {
        let calendar = Calendar.current
        let end = Date() // 현재 시간
        
        // 시간을 제외하고 '날짜'만으로 비교하기 위해 startOfDay 사용
        let startDate = calendar.startOfDay(for: start)
        let endDate = calendar.startOfDay(for: end)
        
        // 날짜 차이 계산
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        
        // 날짜 계산 실패 시 기본값
        guard let days = components.day else { return "방금 전" }
        
        if days == 0 {
            return "오늘"
        } else if days > 0 {
            return "\(days)일 전"
        } else {
            return "방금 전" // 미래의 시간이 들어올 경우 등 예외 처리
        }
    }
}
