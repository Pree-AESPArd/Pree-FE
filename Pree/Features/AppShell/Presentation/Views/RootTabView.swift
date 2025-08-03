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
        } // :ZStack
        .environmentObject(navigationManager)
        .edgesIgnoringSafeArea(.bottom)

        
    }
}
