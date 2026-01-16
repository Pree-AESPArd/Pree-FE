//
//  TakeDTO.swift
//  Pree
//
//  Created by KimDogyung on 1/16/26.
//


struct TakeDTO: Decodable {
    let id: String
    let presentationId: String
    let takeNumber: Int
    let videoKey: String?
    let audioUrl: String?
    let eyeTrackingScore: Int?
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case presentationId = "project_id"
        case takeNumber = "take_number"
        case videoKey = "video_key"
        case audioUrl = "audio_url"
        case eyeTrackingScore = "eye_tracking_score"
        case createdAt = "created_at"
    }
}
