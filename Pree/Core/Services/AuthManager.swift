//
//  AuthManager.swift
//  Pree
//
//  Created by KimDogyung on 1/6/26.
//

import FirebaseAuth
import FirebaseMessaging
import Combine

//TODO: 로그인시 서버에 토큰 보내기 실패한 경우, 처리 로직 필요 (데모용이라 아직 추가 안함)

class AuthManager: ObservableObject {
    static let shared = AuthManager()
    
    // 현재 로그인된 유저 정보 (없으면 nil)
    @Published var user: User?
    
    private var handle: AuthStateDidChangeListenerHandle?
    
    init() {
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.user = user
        }
    }
    
    // 게스트 로그인 함수
    func signInAndSync() async throws {
        // 1. Firebase 익명 로그인 (이미 되어있으면 기존 세션 유지)
        let authResult = try await Auth.auth().signInAnonymously()
        let user = authResult.user
        
        // 2. 서버 동기화 수행 (토큰 전송 및 UUID 저장)
        try await fetchTokensAndSendToServer(user: user)
    }
    
    private func fetchTokensAndSendToServer(user: User) async throws {
        // Step A: ID Token
        let idToken = try await user.getIDTokenResult(forcingRefresh: false).token
        
        // Step B: FCM Token
        let fcmToken = try await Messaging.messaging().token()
        
        // Step C: DTO
        let requestDTO = GuestLoginRequest(
            device_id: user.uid,
            fcm_tocken: fcmToken
        )
        
        // Step D: 서버 전송 (AuthRepository 내부에서 UserStorage.shared.saveUUID 수행)
        try await AuthRepository.shared.sendGuestLogin(request: requestDTO)
        
        print("🚀 [AuthManager] 서버 동기화 및 UUID 저장 완료")
    }
    
    func signOut() {
        try? Auth.auth().signOut()
        UserStorage.shared.clear()
    }
}

