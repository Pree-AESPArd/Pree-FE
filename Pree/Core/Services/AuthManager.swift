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
        // 앱 실행 시 현재 로그인 상태를 실시간 감지
        self.handle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            self?.user = user
            if let user = user {
                // 앱 실행 시 이미 로그인된 상태라면, 토큰을 최신화해서 서버에 알림
                //print("🔄 자동 로그인 감지: 서버와 토큰 동기화 시작")
                Task {
                    await self?.fetchTokensAndSendToServer(user: user)
                }
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
            
            guard let user = authResult?.user else { return }
            //print("🎉 게스트 로그인 성공!")
            
            Task {
                await self.fetchTokensAndSendToServer(user: user)
            }
        }
    }
    
    private func fetchTokensAndSendToServer(user: User) async {
        do {
            // Step A: ID Token 가져오기 (강제 갱신 false)
            // 이 토큰은 1시간 동안 유효하며, 서버에서 verifyIdToken으로 검증 가능
            let idToken = try await user.getIDTokenResult(forcingRefresh: false).token
            
            // Step B: FCM Token 가져오기
            // 푸시 알림을 위해 현재 기기의 고유 토큰을 가져옴
            let fcmToken = try await Messaging.messaging().token()
            
            // Step C: DTO 생성
            let requestDTO = GuestLoginRequest(
                device_id: idToken,
                fcm_tocken: fcmToken,
            )
            
            // Step D: 서버로 전송 (Alamofire)
            try await AuthRepository.shared.sendGuestLogin(request: requestDTO)
            
            print("🚀 모든 로그인 절차 완료 (Firebase + Server Sync)")
            
        } catch {
            print("⚠️ 서버 동기화 실패: \(error.localizedDescription)")
            // 실패 시 정책 결정:
            // 1. 재시도 로직을 넣을지
            // 2. 일단 넘어가고 앱 메인 화면에서 백그라운드로 다시 보낼지
        }
    }
    
    // 로그아웃 (테스트용)
    func signOut() {
        try? Auth.auth().signOut()
    }
}
