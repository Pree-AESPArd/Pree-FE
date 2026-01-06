//
//  AuthManager.swift
//  Pree
//
//  Created by KimDogyung on 1/6/26.
//

import FirebaseAuth
import Combine

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    // 현재 로그인된 유저 정보 (없으면 nil)
    @Published var user: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        // 앱 실행 시 현재 로그인 상태를 실시간 감지
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.user = user
            if let user = user {
                //print("✅ 현재 로그인 상태: UID = \(user.uid)")
                if user.isAnonymous {
                    //print("🎭 (게스트 계정입니다)")
                }
            } else {
                //print("❌ 로그아웃 상태")
            }
        }
    }
    
    // 게스트 로그인 함수
    func signInAsGuest() {
        Auth.auth().signInAnonymously { authResult, error in
            if let error = error {
                print("Error signing in anonymously: \(error.localizedDescription)")
                return
            }
            // 성공하면 위의 addStateDidChangeListener가 자동으로 감지해서 user를 업데이트함
            //print("🎉 게스트 로그인 성공!")
        }
    }
    
    // 로그아웃 (테스트용)
    func signOut() {
        try? Auth.auth().signOut()
    }
}
