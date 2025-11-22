//
//  PracticeMode.swift
//  Pree
//
//  Created by KimDogyung on 11/21/25.
//

enum PracticeMode: Hashable {
    // 새로운 발표 생성 직후 (userId 필요)
    case newCreation(userId: String)
    
    // 기존 발표에 추가 (presentationId 필요)
    case additional(presentationId: String)
}
