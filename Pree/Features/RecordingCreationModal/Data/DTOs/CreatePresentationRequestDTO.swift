//
//  CreatePresentationRequestDTO.swift
//  Pree
//
//  Created by KimDogyung on 1/8/26.
//

import Foundation

struct CreatePresentationRequestDTO: Encodable, Hashable {
    let userId: String
    let presentationName: String
    let idealMinTime: Double
    let idealMaxTime: Double
    let showTimeOnScreen: Bool
    let showMeOnScreen: Bool
    let isDevMode: Bool
}


extension CreatePresentationRequestDTO {
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case presentationName = "title"
        case idealMinTime = "min_duration"
        case idealMaxTime = "max_duration"
        case showTimeOnScreen = "show_timer"
        case showMeOnScreen = "show_camera"
        case isDevMode = "is_dev_mode"
    }
}
