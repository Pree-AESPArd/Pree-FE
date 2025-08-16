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
    case camera
    case profile
    case presentationList
    case practiceResult
    case completeRecording(url: URL)
}

// path에서 현재 completeView에 있는지 확인하기 위함
// completeRecording은 파라미터 값을 받기 때문에 일반적인 if문 비교는 어렵고 깔끔하게 하기 위해 아래와 같이 helper가 필요함
extension ViewType {
    var isCompleteRecording: Bool {
        if case .completeRecording = self { return true }
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
}
