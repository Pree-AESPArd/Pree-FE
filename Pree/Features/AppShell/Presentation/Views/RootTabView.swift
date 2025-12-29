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
//    let cameraViewModel = AppDI.shared.makeCameraViewModel()
    let presnetationListViewModel = AppDI.shared.makePresnetationListViewModel()
    let practiceResultViewModel = AppDI.shared.makePracticeResultViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom){
            NavigationStack(path: $navigationManager.path) {
                HomeView(vm: homeViewModel)
                    .navigationDestination(for: ViewType.self) { path in
                        switch path {
                        case .camera(let presentation):
                            //let cameraViewModel = AppDI.shared.makeCameraViewModel(newPresentation: presentation) 이 방식 쓰면 매번 재실행되면서 새로운 ARView와 ARSession 만들어져서 메모리 에러 남
                            CameraView(presentation: presentation)
                            //                                .toolbarVisibility(.hidden, for: .tabBar)
                        case .home:
                            HomeView(vm: homeViewModel)
                        case .profile:
                            EmptyView()
                        case .presentationList:
                            PresentaionListView(vm: presnetationListViewModel)
                        case .practiceResult:
                            PracticeResultView(vm: practiceResultViewModel)
                        case .completeRecording(let url, let eyeTrackingRate, let mode):
                            CompleteView(videoUrl: url, eyeTrackingRate: rate, practiceMode: mode)
                        }
                    } // : navigationDestination
            } // : NavigationStack
            
            if !((navigationManager.path.last?.isCamera ?? false) ||
                 (navigationManager.path.last?.isCompleteRecording ?? false)) {
                CustomTabView()
            }
            
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
                    
                case .deleteAlert(let onCancel, let onDelete):
                    DeleteAlertView(onCancel: {
                        onCancel()
                        modalManager.hideModal()
                    }, onDelete: {
                        onDelete()
                        modalManager.hideModal()
                    })
                    
                case .standardModal:
                    standardModalView()
                    
//                case .recordingCreationModal:
//                    PresentationListModalView()
//                    
//                case .addNewPresentationModal:
//                    AddNewPresentationModalView()
//                        .transition(.move(edge: .bottom))
                    
                case .none:
                    EmptyView()
                default:
                    EmptyView()
                }
            }
        } // :ZStack
        .environmentObject(navigationManager)
        .environmentObject(modalManager)
        .edgesIgnoringSafeArea(.bottom)

        
    }
}
