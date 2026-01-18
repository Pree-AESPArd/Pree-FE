//
//  FavoriteResponseDTO.swift
//  Pree
//
//  Created by KimDogyung on 1/18/26.
//

import Foundation

struct FavoriteResponseDTO: Decodable {
    let message: String
    let isFavorite: Bool
    
    enum CodingKeys: String, CodingKey {
        case message
        case isFavorite = "is_favorite"
    }
}
