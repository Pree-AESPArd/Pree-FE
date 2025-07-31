//
//  AuthViewModel.swift
//  Pree
//
//  Created by KimDogyung on 7/25/25.
//

import SwiftUI

final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    
    init() {
        // 앱 런치 시, 저장된 토큰(예: UserDefaults or Keychain) 검사
        let token = UserDefaults.standard.string(forKey: "authToken")
        isSignedIn = (token != nil)
    }
    
    func login(username: String, password: String) {
        // 실제는 네트워크 호출 → 토큰 받아오기 로직
        // 여기서는 간단히 성공 처리 예시
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let fakeToken = "ABC123"
            UserDefaults.standard.set(fakeToken, forKey: "authToken")
            self.isSignedIn = true
        }
    }
    
    func logout() {
        UserDefaults.standard.removeObject(forKey: "authToken")
        isSignedIn = false
    }
    
}
