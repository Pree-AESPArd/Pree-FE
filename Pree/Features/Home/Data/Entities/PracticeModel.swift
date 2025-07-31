//
//  PracticeModel.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import Foundation

// ToDo: API 명세서 나오면 수정 필요
struct PracticeModel: Hashable, Identifiable {
    let id: UUID = UUID()
    let title: String
    let count: Int
    let dateDiff: Int
    let score: Double
    let bookmark: Bool = false
    let select: Bool? = false
}
