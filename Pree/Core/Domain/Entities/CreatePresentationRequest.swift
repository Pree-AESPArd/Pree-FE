//
//  CreatePresentationRequest.swift
//  Pree
//
//  Created by KimDogyung on 9/11/25.
//

import Foundation

struct CreatePresentationRequest: Encodable, Hashable{
    let presentationName: String
    let idealMinTime: Double
    let idealMaxTime: Double
    let showTimeOnScreen: Bool
    let showMeOnScreen: Bool
}


struct ResponseForNewPresentation: Codable {
    var presentationId: String?
    var presentationName: String?
    var createdAt: String?
}
