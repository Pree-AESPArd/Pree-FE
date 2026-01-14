//
//  UserStorage.swift
//  Pree
//
//  Created by KimDogyung on 1/14/26.
//


import Foundation

class UserStorage {
    static let shared = UserStorage()
    
    private let key = "server_user_uuid"
    
    // UUID 저장
    func saveUUID(_ uuid: String) {
        UserDefaults.standard.set(uuid, forKey: key)
        print("💾 [UserStorage] Server UUID 저장 완료: \(uuid)")
    }
    
    // UUID 꺼내기
    func getUUID() -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
    // 로그아웃 시 삭제
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

