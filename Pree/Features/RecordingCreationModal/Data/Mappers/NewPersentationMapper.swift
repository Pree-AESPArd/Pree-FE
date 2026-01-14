//
//  NewPersentationMapper.swift
//  Pree
//
//  Created by KimDogyung on 1/8/26.
//

import Foundation

enum NewPresentationMapper {
    static func toEntity(_ dto: CreatePresentationResponseDTO) throws -> NewPresentation {
//        guard let date = ISO8601DateFormatter().date(from: dto.createdAt) else {
//            throw MappingError.invalidData
//        }
//        return .init(id: dto.presentationId, name: dto.presentationName, createdAt: date)
        
        return .init(id: dto.presentationId, name: dto.presentationName)
    }
}
