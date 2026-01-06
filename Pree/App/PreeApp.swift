//
//  PreeApp.swift
//  Pree
//
//  Created by KimDogyung on 7/24/25.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    return true
  }
}

@main
struct PreeApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
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

