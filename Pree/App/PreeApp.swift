//
//  PreeApp.swift
//  Pree
//
//  Created by KimDogyung on 7/24/25.
//

import SwiftUI

@main
struct PreeApp: App {
    
    @StateObject private var authVM = AuthViewModel()
    
    init() {
        
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authVM.isSignedIn {
                    RootTabView()
                } else {
                    LaunchSignInView()
                }
            }
            .environmentObject(authVM)
        }
    }
}

