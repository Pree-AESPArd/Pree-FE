//
//  GuestLoginRequest.swift
//  Pree
//
//  Created by KimDogyung on 1/7/26.
//

import Foundation

struct GuestLoginRequest: Encodable {
    let device_id: String   // Firebase가 발급한 보증수표 (이 안에 UID가 들어있음)
    let fcm_token: String  // 푸시 알림을 보낼 주소
    
}
