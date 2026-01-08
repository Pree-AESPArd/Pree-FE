//
//  PreeApp.swift
//  Pree
//
//  Created by KimDogyung on 7/24/25.
//

import SwiftUI
import FirebaseCore
import FirebaseMessaging
import FirebaseAuth

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        // 알림 권한 요청 (사용자에게 "알림을 허용하시겠습니까?" 팝업 띄우기)
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        // 2. 🚀 애플 서버(APNS)에 원격 알림 등록 요청
        application.registerForRemoteNotifications()
        
        // 3. 메시징 델리게이트 설정
        Messaging.messaging().delegate = self
        
        return true
    }
    
    // FCM 토큰 갱신 감지 및 알림 처리 델리게이트
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("🍏 APNS Token 받음: \(deviceToken)")
        
        // Firebase에 APNS 토큰을 명시적으로 연결
        Messaging.messaging().apnsToken = deviceToken
    }
    
    // APNS 토큰 발급 실패 시
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("🍎 APNS 등록 실패: \(error)")
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



extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    
    // FCM 토큰이 갱신될 때 호출됨
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        guard let fcmToken = fcmToken else {
            print("⚠️ FCM 토큰이 nil입니다.")
            return
        }
        
        print("🔥 Firebase FCM Token 갱신됨: \(String(describing: fcmToken))")
        
        // 토큰이 갱신될 때마다 서버에 업데이트 요청을 보내기
        // 현재 로그인된 유저가 있을 때만 서버에 알려줌
        if let currentUser = Auth.auth().currentUser {
            Task {
                do {
                    // Firebase ID Token도 새로 가져옴
                    let idToken = try await currentUser.getIDTokenResult().token
                    
                    let requestDTO = GuestLoginRequest(
                        device_id: idToken,
                        fcm_tocken: fcmToken
                    )
                    
                    // 서버 API 호출 (토큰 업데이트용)
                    // 기존 로그인 API와 같은 URL을 써도 서버에서 UID를 식별자로 하여 덮어쓰기
                    try await AuthRepository.shared.sendGuestLogin(request: requestDTO)
                    print("🚀 서버에 새 FCM 토큰 동기화 완료")
                    
                } catch {
                    print("⚠️ 토큰 자동 갱신 실패: \(error)")
                    //TODO: 실패 시 나중에 다시 시도할 수 있도록 처리하기 (데모용이라 구현 안함)
                }
            }
        }
    }
    
    // 앱이 실행 중일 때 알림이 오면 처리
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .list, .sound])
    }
}
