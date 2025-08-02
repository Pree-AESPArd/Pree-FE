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
