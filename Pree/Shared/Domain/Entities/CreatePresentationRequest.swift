//
//  CreatePresentationRequest.swift
//  Pree
//
//  Created by KimDogyung on 9/11/25.
//

import Foundation

struct CreatePresentationRequest: Encodable {
    let presentationName: String
    let idealMinTime: Double
    let idealMaxTime: Double
    let showTimeOnScreen: Bool
    let showMeOnScreen: Bool
}
