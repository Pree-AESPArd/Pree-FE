//
//  CalibrationView.swift
//  Pree
//
//  Created by KimDogyung on 8/3/25.
//


import SwiftUI

struct EyeTrackingCalibrationView: View {
    @ObservedObject var vm: CameraViewModel
    
    @State private var currentIndex: Int = -1
    @State private var collectedGazePoints: [[CGPoint]] = []
    @State private var isStarted: Bool = false
    @State private var isCollecting = false

    // 총 9개의 포인트를 담을 배열. GeometryReader 안에서 화면 크기에 맞춰 계산합니다.
    private func positions(in size: CGSize) -> [CGPoint] {
        let w = size.width
        let h = size.height
        // 화면 모서리에서 8% 안쪽으로 인셋
        let mx = w * 0.08, my = h * 0.08
        // 중간 지점은 30% 안쪽으로 인셋
        let midMx = w * 0.30, midMy = h * 0.30

        return [
            // Outer ring (8 points)
            CGPoint(x: mx,     y: my),
            CGPoint(x: w/2,    y: my),
            CGPoint(x: w - mx, y: my),
            CGPoint(x: w - mx, y: h/2),
            CGPoint(x: w - mx, y: h - my),
            CGPoint(x: w/2,    y: h - my),
            CGPoint(x: mx,     y: h - my),
            CGPoint(x: mx,     y: h/2),
            
            // Inner ring (4 points)
            CGPoint(x: midMx,     y: midMy),
            CGPoint(x: w - midMx, y: midMy),
            CGPoint(x: w - midMx, y: h - midMy),
            CGPoint(x: midMx,     y: h - midMy),

            // Center (1 point)
            CGPoint(x: w/2, y: h/2)
        ]
    }
    
    
    var body: some View {
        GeometryReader { geo in
            let pts = positions(in: geo.size)
            ZStack {
                Color.black
                    .opacity(1.0)
                    .edgesIgnoringSafeArea(.all)
                
            
                if !isStarted {
                    descriptionText
                }

                
                // currentIndex 가 유효 범위일 때만 하나의 원을 찍어준다
                if currentIndex >= 0 && currentIndex < pts.count {
                    let pt = positions(in: geo.size)[currentIndex]
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 20, height: 20)
                        .position(pt)
                        .animation(.easeInOut, value: currentIndex)
                }
                
                // 포인트 UI 확인용 코드
//                ForEach(positions(in: geo.size), id: \.self) {pt in
//                    Circle()
//                        .fill(Color.primary)
//                        .frame(width: 20, height: 20)
//                        .position(pt)
//                        .animation(.easeInOut, value: currentIndex)
//                }
                
                
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                collectedGazePoints = Array(repeating: [], count: pts.count)
                DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                    isStarted = true
                    showNext(at: 0, total: pts.count, targets: pts) 
                }
                
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onChange(of: vm.gazePoint) {
                guard currentIndex >= 0,
                      currentIndex < collectedGazePoints.count
                else { return }
                collectedGazePoints[currentIndex].append(vm.gazePoint)
            }
        }
    }
    
    
    // circle 애니메이션 제어
    private func showNext(at idx: Int, total: Int, targets: [CGPoint]) {
        guard idx < total else {
            vm.isCalibrating = false
            vm.isDoneCalibration = true
            vm.processAndStoreCalibration(targets: targets, samples: collectedGazePoints) // ← 캘리브레이션 적용!
            return
        }
        
        currentIndex = idx
        isCollecting = false
        
        // ① 정착 시간(250ms) 대기 후
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // ② 수집 시작(900ms 고정 윈도우)
            isCollecting = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                isCollecting = false
                // 다음 점으로
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showNext(at: idx + 1, total: total, targets: targets)
                }
            }
        }
    }
    
    
    private var descriptionText: some View {
        Text("움직이는 점을 따라 응시해주세요")
            .font(.pretendardSemiBold(size: 16))
            .foregroundStyle(.white)
    }
    
    
}



//#Preview {
//    let vm = AppDI.shared.makeCameraViewModel()
//    EyeTrackingCalibrationView(vm: vm)
//}
