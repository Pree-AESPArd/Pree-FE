//
//  CreatePresentationRequestMapper.swift
//  Pree
//
//  Created by KimDogyung on 1/9/26.
//

import Foundation

enum CreatePresentationRequestMapper {
    static func toDTO(_ request: CreatePresentationRequest) -> CreatePresentationRequestDTO {
        CreatePresentationRequestDTO(
            userId: request.userId,
            presentationName: request.name,
            idealMinTime: request.idealMinTime,
            idealMaxTime: request.idealMaxTime,
            showTimeOnScreen: request.showTimeOnScreen,
            showMeOnScreen: request.showMeOnScreen,
            isDevMode: request.isDevMode
        )
    }
}
