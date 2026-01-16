//
//  CreatePresentationRequest.swift
//  Pree
//
//  Created by KimDogyung on 9/11/25.
//

import Foundation

struct CreatePresentationRequest: Equatable, Hashable {
    let userId: String
    let name: String
    let idealMinTime: TimeInterval
    let idealMaxTime: TimeInterval
    let showTimeOnScreen: Bool
    let showMeOnScreen: Bool
    let isDevMode: Bool
}

