//
//  UserResponseDTO.swift
//  Pree
//
//  Created by KimDogyung on 1/14/26.
//

import Foundation

struct UserResponseDTO: Decodable {
    let id: String
    let deviceId: String
    let fcmToken: String?
    let createAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case deviceId = "device_id"
        case fcmToken = "fcm_token"
        case createAt = "created_at"
    }
}
