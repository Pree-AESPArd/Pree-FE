//
//  AuthViewModel.swift
//  Pree
//
//  Created by KimDogyung on 7/25/25.
//

import SwiftUI
import Combine

final class AuthViewModel: ObservableObject {
    @Published var isSignedIn: Bool = false
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // AuthManager의 user 상태를 구독합니다.
        // user가 nil이 아니면(로그인 됨) -> isSignedIn = true
        // user가 nil이면(로그아웃 됨) -> isSignedIn = false
        AuthManager.shared.$user
            .receive(on: DispatchQueue.main)
            .map { $0 != nil }
            .assign(to: \.isSignedIn, on: self)
            .store(in: &cancellables)
    }
    
    func signInAsGuest() {
        AuthManager.shared.signInAsGuest()
    }
    
    func logout() {
        AuthManager.shared.signOut()
    }
    
}
