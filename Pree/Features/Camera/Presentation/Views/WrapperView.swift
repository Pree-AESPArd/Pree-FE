//
//  WrapperView.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI

struct WrapperView: View {
    let vm = AppDI.shared.makeCameraViewModel()
    
    var body: some View {
        NavigationStack{
                NavigationLink("카메라") {
                    CameraView(vm: vm)
                        .toolbarVisibility(.hidden, for: .tabBar)
                }
                .foregroundStyle(.primary)
            
        }
    }
}
