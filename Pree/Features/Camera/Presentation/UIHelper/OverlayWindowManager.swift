//
//  OverlayWindowManager.swift
//  Pree
//
//  Created by KimDogyung on 7/29/25.
//

import SwiftUI
import UIKit

/// 1) A SwiftUI-friendly manager that owns your extra UIWindow
final class OverlayWindowManager: ObservableObject {
  private(set) var overlayWindow: UIWindow?

    //  1. func show<Content: View>
    //      •    이 함수는 제네릭(Generic) 으로, 타입 매개변수 Content를 받습니다.
    //      •    Content는 View 프로토콜을 준수해야(: View) 하므로, SwiftUI의 어떤 View 타입이든 사용할 수 있어요.
    
    // 2.    (@ViewBuilder content: () -> Content)
    //    •    content라는 이름의 파라미터는 클로저(Closure) 입니다.
    //    •    클로저 시그니처가 () -> Content 이므로, 매개변수 없이 실행해서 Content 타입의 값을 반환해야 해요.
    //    •    @ViewBuilder 어트리뷰트 덕분에, 이 클로저 안에서 여러 개의 뷰를 나열하거나 if, ForEach 같은 SwiftUI 뷰 빌더 문법을 바로 쓸 수 있습니다.
    
    // 어떤 타입의 View든 받아들여서 클로저 는 “그 뷰를 만들어서 반환(factory)해 주는” 역할
  func show<Content: View>(@ViewBuilder content: () -> Content) {
    guard overlayWindow == nil else { return }

    // ① Grab the active UIWindowScene
      
    // UIApplication.shared.connectedScenes: 씬(Scene) API로, 앱에 연결된 모든 UIScene 객체(보통 UIWindowScene)들의 집합(Set<UIScene>)을 반환
    // first(where: { $0.activationState == .foregroundActive }): 그 중에서 activationState가 .foregroundActive, 즉 “사용자 눈앞에 현재 보이고 있는” 씬을 찾아 옵니다
    // first(where:)는 조건을 만족하는 첫 번째 요소를 돌려주며, 없으면 nil이 됩니다.
    // as? UIWindowScene: connectedScenes의 요소 타입은 일반 UIScene이기 때문에, 실제로 UIWindowScene인지를 안전하게 다운캐스트
    guard let windowScene = UIApplication.shared
            .connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
    else { return }

    // ② Host a SwiftUI view in a UIHostingController
    // SwiftUI 뷰를 UIKit UIViewController 로 감싸서 화면에 띄우겠다
    let host = UIHostingController(rootView: content())
    
    host.view.backgroundColor = .clear

    // ③ Create your new overlay UIWindow
    let w = UIWindow(windowScene: windowScene)
    w.windowLevel      = .alert + 1        // 위에 뜨게
    w.isOpaque         = false             // 투명 허용
    w.backgroundColor  = .clear            // 뒤 내용이 보여야 하니 완전 투명
    w.rootViewController = host
    w.makeKeyAndVisible()
    
    overlayWindow = w
  }

  /// Tear it down
  func hide() {
    overlayWindow?.isHidden = true
    /*self.overlayWindow?.rootViewController = nil*/ // 새로 추가
    overlayWindow = nil
  }
}
