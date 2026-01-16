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
            
            if let user = Auth.auth().currentUser {
                Task {
                    try? await AuthManager.shared.signInAndSync() // 내부 로직 재활용
                }
            }
            
        } else {
            self.isSignedIn = false
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
