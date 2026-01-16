//
//  CompleteView.swift
//  Pree
//
//  Created by KimDogyung on 8/17/25.
//

import SwiftUI


struct CompleteView: View {
    @StateObject var vm: CompleteViewModel
    @EnvironmentObject var navigationManager: NavigationManager
    
    init(presentationId: String, videoUrl: URL, eyeTrackingRate: Int) {
        self._vm = StateObject(wrappedValue: AppDI.shared.makeCompleteViewModel(
            presentationId: presentationId,
            videoUrl: videoUrl,
            eyeTrackingRate: eyeTrackingRate,
        ))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            
            CircularLoadingView()
                .frame(width: 46, height: 46)
            
            waitngText
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            vm.processVideo()
        }
        .alert("분석 요청 완료", isPresented: $vm.isUploadComplete) {
            Button("확인") {
                // 확인 버튼을 누르면 홈으로 이동!
                navigationManager.popToRoot()
            }
        } message: {
            Text("서버에서 분석이 시작되었습니다.\n완료되면 푸시 알림으로 알려드릴게요!")
        }
        // 에러 알림창 (기존 로직 유지 또는 추가)
        .alert("오류 발생", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("확인") {
                navigationManager.popToRoot() // 에러 나면 일단 홈으로
            }
        } message: {
            if let errorMsg = vm.errorMessage {
                Text(errorMsg)
            }
        }
        
    }
    
    private var waitngText: some View {
        Text("리포트를 생성중이에요...")
            .font(.pretendardMedium(size: 14))
            .foregroundStyle(Color.primary)
    }
    
}


struct CircularLoadingView: View {
    // State to control the animation
    @State private var isAnimating = false
    
    // Customizable properties
    var color: Color = .blue
    var lineWidth: CGFloat = 2
    
    var body: some View {
        Circle()
        // 1. Trim the circle to create an arc
            .trim(from: 0, to: 0.7)
        // 2. Style it as a stroke (an outline)
            .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
        // 3. Rotate the arc
            .rotationEffect(.degrees(isAnimating ? 360 : 0))
        // 4. Set up the animation
            .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false), value: isAnimating)
        // 5. Start the animation when the view appears
            .onAppear {
                self.isAnimating = true
            }
    }
}





//#Preview {
//    let url: URL = URL(string: "https://www.youtube.com/watch?v=dQw4w9WgXcQ")!
//    CompleteView(videoUrl: url)
//}
