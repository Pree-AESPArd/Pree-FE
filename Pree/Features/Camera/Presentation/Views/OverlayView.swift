//
//  OverlayView.swift
//  Pree
//
//  Created by KimDogyung on 7/29/25.
//

// 영상촬영 화면 위에 보이는 버튼과 안내문구 요소를 보여주기 위한 뷰
// 화면 녹화시 이 화면은 유저에게는 보이지만 화면 녹화에는 녹화되지 않음

import SwiftUI

struct OverlayView: View {
    
    @ObservedObject var vm: CameraViewModel
    @ObservedObject var overlayManager: OverlayWindowManager
    @EnvironmentObject var navigationManager: NavigationManager
    
    @State private var showPopWarningAlert: Bool = false
    @State private var showFinishRecordAlert: Bool = false
    
    var body: some View {
        
        Group {
            if vm.isCalibrating {
                EyeTrackingCalibrationView(vm: vm)
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        
                        popButton
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 12)
                        
                        if !vm.isCapturing {
                            descriptionText
                        } else {
                            timerText
                        }
                        
                        if vm.isDebugMode {
                            eyeTrackingTimer
                        }
                        
                        Spacer()
                        
                        if !vm.isCapturing {
                            Image("face_guide")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: geometry.size.width * 0.65) // 화면 너비의 60% 크기
                                .frame(maxWidth: .infinity) // 가운데 정렬
                        }
                        
                        Spacer()
                        
                        PrimaryButton(
                            title: vm.isDoneCalibration ? (vm.isCapturing ? "촬영 마치기" : "촬영 시작하기") : "눈 추적 조정 시작",
                            action: {
                                
                                if vm.isDoneCalibration {
                                    if vm.isCapturing {
                                        // 촬영 종료 alert를 띄움
                                        showFinishRecordAlert = true
                                    } else {
                                        // 촬영 시작
                                        vm.toggleCapture()
                                    }
                                } else {
                                    vm.startCalibration()
                                }
                            }
                        )
                    }
                    .appPadding()
                    // alert는 커스텀 스타일 적용 못함
                    // text에 폰트나 색상 바꾸고 싶으면 confirmationDialog 사용
                    .alert("뒤로가기", isPresented: $showPopWarningAlert) {
                        Button("뒤로가기", role: .destructive) {
                            // "뒤로가기" 버튼을 눌렀을 때 실행될 액션
                            overlayManager.hide()
                            navigationManager.pop()
                        }
                        Button("취소", role: .cancel) {
                            // 취소 버튼은 자동으로 알림창을 닫습니다.
                        }
                    } message: {
                        Text("뒤로가기를 누르면 영상이 저장되지 않습니다. 리포트를 확인하려면 촬영 마치기를 눌러주세요.")
                    }
                    .alert("촬영 마치기", isPresented: $showFinishRecordAlert) {
                        Button("마치기", role: .destructive) {
                            vm.toggleCapture()
                        }
                        Button("취소", role: .cancel) {
                            
                        }
                    } message: {
                        Text("촬영이 종료됩니다. 자동 저장 후 리포트가 바로 생성됩니다!")
                    }
                    // url이 생성되면 자동으로 화면 전환
                    .onChange(of: vm.videoURL) {
                        if let url = vm.videoURL, let rate = vm.eyeTrackingRate {
                            overlayManager.hide()
                            navigationManager.push(.completeRecording(url: url, eyeTrackingRate: rate, mode: vm.currentPracticeMode))
                        }
                    }
                }
            }
            
        }
        
    }
    
    
    private var popButton: some View {
        Button(
            action: {
                if vm.isCapturing {
                    showPopWarningAlert = true
                } else {
                    overlayManager.hide() // Overaly 된 UI 요소들을 없애줌, CameraView 안에서 onDisappear 에서 실행하면 바로 안없어지고 잠시 남아있다가 사라짐
                    navigationManager.pop()
                }
            },
            label: {
                Image(systemName: "chevron.left")
                    .frame(width: 24, height: 24)
                    .foregroundColor(.white)
            }
        )
    }
    
    private var descriptionText: some View {
        Text("얼굴을 프레임에 맞추고\n 중심의 점을 바라봐주세요")
            .font(.pretendardMedium(size: 14))
            .foregroundStyle(Color.primary)
            .multilineTextAlignment(.center)
            .padding(8)
            .background(.white)
            .cornerRadius(20)
    }
    
    private var timerText: some View {
        Text("\(vm.timerString)")
            .font(.pretendardMedium(size: 20))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.preeRed)
            .cornerRadius(4)
    }
    
    private var eyeTrackingTimer: some View {
        Text("\(vm.eyeTrackingTimerString)")
            .font(.pretendardMedium(size: 20))
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.primary)
            .cornerRadius(4)
        
    }
    
}



#Preview {
    let vm = AppDI.shared.makeCameraViewModel()
    let overlayManager = OverlayWindowManager()
    OverlayView(vm: vm, overlayManager: overlayManager)
        .environmentObject(NavigationManager())
}
