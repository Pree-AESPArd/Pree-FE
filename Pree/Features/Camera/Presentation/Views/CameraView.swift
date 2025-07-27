//
//  CameraView.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI

struct CameraView: View {
    @StateObject var vm: CameraViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Text(vm.isRecording ? "🔴 Recording…" : "⏺️ Ready to record")
            Button(vm.isRecording ? "Stop Recording" : "Start Recording") {
                vm.toggleRecording()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(vm.isRecording ? .red : .blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .sheet(isPresented: $vm.showPreview) {
            if let preview = vm.previewController {
                ScreenPreviewController(preview: preview)
            }
        }
    }
}






#Preview {
    let vm = AppDI.shared.makeCameraViewModel()
    CameraView(vm: vm)
}
