//
//  ModalManager.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

enum ModalType {
    // 이름 수정 알림 모달
    case editAlert(onCancel: () -> Void, onConfirm: (String) -> Void)
    //삭제 확인 알림 모달
    case deleteAlert(onCancel: () -> Void, onDelete: () -> Void)
    // 평가 기준 표준 모달
    case standardModal
}

// 앱 전체의 모달을 중앙 집중식으로 관리
// RootTabView에서 모든 모달을 표시하고, 각 뷰에서는 이 매니저를 통해 모달을 요청
class ModalManager: ObservableObject {
    static let shared = ModalManager()
    private init() {}
    
    @Published var currentModal: ModalType? // 현재 표시할 모달 타입
    @Published var isShowingModal = false //모달 표시 여부
    
    // 이름 수정 알림 모달을 표시
    func showEditAlert(onCancel: @escaping () -> Void, onConfirm: @escaping (String) -> Void) {
        currentModal = .editAlert(onCancel: onCancel, onConfirm: onConfirm)
        isShowingModal = true
    }
    
    // 삭제 확인 알림 모달을 표시
    func showDeleteAlert(onCancel: @escaping () -> Void, onDelete: @escaping () -> Void) {
        currentModal = .deleteAlert(onCancel: onCancel, onDelete: onDelete)
        isShowingModal = true
    }
    
    // 평가 기준 표준 모달을 표시
    func showStandardModal() {
        currentModal = .standardModal
        isShowingModal = true
    }
    
    // 현재 표시 중인 모달을 숨김
    func hideModal() {
        isShowingModal = false
        currentModal = nil
    }
} 
