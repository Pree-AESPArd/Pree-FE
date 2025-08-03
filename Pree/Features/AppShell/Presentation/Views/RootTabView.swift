//
//  RootTabView.swift
//  Pree
//
//  Created by KimDogyung on 7/25/25.
//

import SwiftUI

enum Tab { case home, profile }

struct RootTabView: View {
    @StateObject private var navigationManager = NavigationManager()
    @StateObject private var modalManager = ModalManager.shared
    let homeViewModel = AppDI.shared.makeHomeViewModel()
    let cameraViewModel = AppDI.shared.makeCameraViewModel()
    let presnetationListViewModel = AppDI.shared.makePresnetationListViewModel()
    let practiceResultViewModel = AppDI.shared.makePracticeResultViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom){
            NavigationStack(path: $navigationManager.path) {
                HomeView(vm: homeViewModel)
                    .navigationDestination(for: ViewType.self) { path in
                        switch path {
                        case .camera:
                            CameraView(vm: cameraViewModel)
                        case .home:
                            HomeView(vm: homeViewModel)
                        case .profile:
                            EmptyView()
                        case .presentationList:
                            PresentaionListView(vm: presnetationListViewModel)
                        case .practiceResult:
                            PracticeResultView(vm: practiceResultViewModel)
                        }
                    } // : navigationDestination
            } // : NavigationStack
            
            CustomTabView()
            
            // 모달 오버레이
            if modalManager.isShowingModal {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        modalManager.hideModal()
                    }
                
                switch modalManager.currentModal {
                case .editAlert(let onCancel, let onConfirm):
                    EditAlertView(onCancel: {
                        onCancel()
                        modalManager.hideModal()
                    }, onConfirm: { text in
                        onConfirm(text)
                        modalManager.hideModal()
                    })
                    .environmentObject(modalManager)
                    
                case .deleteAlert(let onCancel, let onDelete):
                    DeleteAlertView(onCancel: {
                        onCancel()
                        modalManager.hideModal()
                    }, onDelete: {
                        onDelete()
                        modalManager.hideModal()
                    })
                    .environmentObject(modalManager)
                    
                case .standardModal:
                    standardModalView()
                        .environmentObject(modalManager)
                    
                case .none:
                    EmptyView()
                }
            }
        } // :ZStack
        .environmentObject(navigationManager)
        .environmentObject(modalManager)
        .edgesIgnoringSafeArea(.bottom)

        
    }
}
