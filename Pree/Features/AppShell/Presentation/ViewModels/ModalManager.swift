//
//  ModalManager.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

enum ModalType {
    case editAlert(onCancel: () -> Void, onConfirm: (String) -> Void)
    case deleteAlert(onCancel: () -> Void, onDelete: () -> Void)
    case standardModal
}

class ModalManager: ObservableObject {
    static let shared = ModalManager()
    
    @Published var currentModal: ModalType?
    @Published var isShowingModal = false
    
    private init() {}
    
    func showEditAlert(onCancel: @escaping () -> Void, onConfirm: @escaping (String) -> Void) {
        currentModal = .editAlert(onCancel: onCancel, onConfirm: onConfirm)
        isShowingModal = true
    }
    
    func showDeleteAlert(onCancel: @escaping () -> Void, onDelete: @escaping () -> Void) {
        currentModal = .deleteAlert(onCancel: onCancel, onDelete: onDelete)
        isShowingModal = true
    }
    
    func showStandardModal() {
        currentModal = .standardModal
        isShowingModal = true
    }
    
    func hideModal() {
        isShowingModal = false
        currentModal = nil
    }
} 