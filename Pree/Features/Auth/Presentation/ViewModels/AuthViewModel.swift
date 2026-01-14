//
//  AuthViewModel.swift
//  Pree
//
//  Created by KimDogyung on 7/25/25.
//

import SwiftUI
import Combine
import FirebaseAuth

final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var isLoading: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        
        checkLoginStatus()
        
    }
    
    private func checkLoginStatus() {
        let hasFirebaseUser = Auth.auth().currentUser != nil
        let hasUUID = UserStorage.shared.getUUID() != nil
        
        if hasFirebaseUser && hasUUID {
            self.isSignedIn = true
        } else {
            self.isSignedIn = false
            // 만약 hasFirebaseUser는 true인데 hasUUID가 false라면? (앱 재설치 상황)
            // -> isSignedIn = false로 둬서 로그인 화면을 보여주고,
            // -> 사용자가 "게스트 시작" 버튼을 누르면 서버에서 다시 UUID를 받아오게 유도함.
        }
    }
    
    func signInAsGuest() {
        guard !isLoading else { return }
        isLoading = true
        
        Task {
            // 네트워크 작업은 백그라운드에서 실행됨
            do {
                try await AuthManager.shared.signInAndSync()
                
                await MainActor.run {
                    self.isSignedIn = true
                    self.isLoading = false
                    print("🎉 로그인 프로세스 완료 -> 홈으로 이동")
                }
                
            } catch {
                print("❌ 로그인 실패: \(error)")
                
                await MainActor.run {
                    self.isSignedIn = false
                    self.isLoading = false
                    // 필요한 경우 에러 알림 표시
                }
            }
        }
    }
    
    func logout() {
        AuthManager.shared.signOut()
        self.isSignedIn = false
    }
    
}
