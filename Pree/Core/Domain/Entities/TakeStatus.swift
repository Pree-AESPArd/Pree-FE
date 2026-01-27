//
//  TakeStatus.swift
//  Pree
//
//  Created by KimDogyung on 1/27/26.
//

import Foundation

enum TakeStatus: String, Codable {
    case pending = "PENDING"
    case processing = "PROCESSING"
    case completed = "COMPLETED"
    case failed = "FAILED"
    case unknown
    
    // 디코딩 실패 방지를 위한 커스텀 init
    public init(from decoder: Decoder) throws {
        self = try TakeStatus(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
