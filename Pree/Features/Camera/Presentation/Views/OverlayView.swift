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
    
    var body: some View {
        
        Group {
            if vm.isCalibrating {
                EyeTrackingCalibrationView(vm: vm)
            } else {
                GeometryReader { geometry in
                    VStack(spacing: 0) {
                        
                        backButton
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 12)
                        
                        if !vm.isCapturing {
                            descriptionText
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
                                    vm.toggleCapture()
                                } else {
                                    vm.startCalibration()
                                }
                            }
                        )
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.white)
                        }
                    }
                    .appPadding()
                }
            }
        }
        
    }
    
    
    private var backButton: some View {
        Button(
            action: {
                overlayManager.hide() // Overaly 된 UI 요소들을 없애줌, CameraView 안에서 onDisappear 에서 실행하면 바로 안없어지고 잠시 남아있다가 사라짐
                navigationManager.pop()
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
    
}


