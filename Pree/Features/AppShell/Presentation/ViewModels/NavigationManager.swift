//
//  NavigationManager.swift
//  Pree
//
//  Created by 이유현 on 8/3/25.
//

import Foundation
import SwiftUI

enum ViewType: Hashable {
    case home
    case camera(presentation: Presentation)
    case profile
    case presentationDetail(presentation: Presentation)
    case practiceResult
    case completeRecording(presentationId: String, url: URL, eyeTrackingRate: Int)
}

// path에서 현재 completeView에 있는지 확인하기 위함
// completeRecording은 파라미터 값을 받기 때문에 일반적인 if문 비교는 어렵고 깔끔하게 하기 위해 아래와 같이 helper가 필요함
extension ViewType {
    var isCompleteRecording: Bool {
        if case .completeRecording = self { return true }
        return false
    }
    
    var isCamera: Bool {
        if case .camera = self { return true }
        return false
    }
}

final class NavigationManager: ObservableObject {
    @Published var path: [ViewType] = []
    
    func push(_ view: ViewType) {
        path.append(view)
    }
    
    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeAll()
    }
    
    func navigateTo(_ view: ViewType) {
        path = [view]
    }
    
    func handlePushNotification(userInfo: [AnyHashable: Any]) {
        // 1. 데이터 파싱 (서버랑 키값 약속 필요)
        // 예: {"type": "REPORT", "presentation_id": "123", "take_id": "456"}
        guard let type = userInfo["type"] as? String else { return }
        
        // 메인 스레드에서 UI 변경 보장
        DispatchQueue.main.async {
            if type == "REPORT" {
                // 2. 필요한 ID 추출
                guard let presentationId = userInfo["presentation_id"] as? String,
                      let takeId = userInfo["take_id"] as? String else { return }
                
                print("🚀 리포트 화면으로 이동 시도: \(presentationId), \(takeId)")
                
                // 3. 네비게이션 스택 초기화 (홈으로)
                self.popToRoot()
                
                // 4. 리포트 상세 화면으로 이동
                // (참고: ViewType에 .practiceResult 같은 상세 화면 케이스가 있어야 함)
                // 예시: self.push(.practiceResult(presentationId: presentationId, takeId: takeId))
                
                // ⚠️ 현재 ViewType에 파라미터 받는 practiceResult가 없다면 추가해야 합니다.
                // 임시 코드:
                self.push(.practiceResult)
            }
        }
    }
    
}
