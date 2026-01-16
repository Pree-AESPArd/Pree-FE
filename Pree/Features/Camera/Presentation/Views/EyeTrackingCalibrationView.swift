//
//  CalibrationView.swift
//  Pree
//
//  Created by KimDogyung on 8/3/25.
//

import SwiftUI

struct EyeTrackingCalibrationView: View {
    @ObservedObject var vm: CameraViewModel
    
    // MARK: - State Variables
    @State private var currentIndex: Int = -1
    @State private var collectedGazePoints: [[CGPoint]] = []
    
    // 화면 상태
    @State private var isStarted: Bool = false      // 캘리브레이션 시작 여부
    @State private var isCollecting: Bool = false   // 현재 데이터 수집 중인지
    
    // 카운트다운용 변수
    @State private var startCountdown: Int = 3      // 시작 전 카운트 (3, 2, 1)
    @State private var dotCountdown: Int = 2        // 각 점마다 남은 시간 (초)

    // 총 13개의 포인트를 담을 배열
    private func positions(in size: CGSize) -> [CGPoint] {
        let w = size.width
        let h = size.height
        let mx = w * 0.08, my = h * 0.08
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
                
                // 1. 시작 전 대기 화면 (문구 + 카운트다운)
                if !isStarted {
                    VStack(spacing: 20) {
                        descriptionText
                        
                        // 시작 카운트다운 숫자
                        Text("\(startCountdown)")
                            .font(.pretendardBold(size: 60))
                            .foregroundColor(.yellow)
                            .transition(.opacity) // 숫자가 바뀔 때 깜빡이는 효과
                            .id("start_\(startCountdown)") // 숫자가 바뀔 때마다 뷰 갱신
                    }
                }

                // 2. 캘리브레이션 점 (원 + 내부 카운트다운)
                if currentIndex >= 0 && currentIndex < pts.count {
                    let pt = pts[currentIndex]
                    
                    // 원 안에 숫자를 넣기 위해 ZStack 사용
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 40, height: 40)
                        
                        // 수집 중일 때만 숫자 표시 (이동 중엔 숨김)
                        if isCollecting {
                            Text("\(dotCountdown)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    .position(pt)
                    .animation(.easeInOut(duration: 0.3), value: currentIndex) // 점 이동 애니메이션
                }
            }
            .onAppear {
                UIApplication.shared.isIdleTimerDisabled = true
                // 데이터 담을 그릇 초기화
                collectedGazePoints = Array(repeating: [], count: pts.count)
                
                // ⭐️ 전체 시퀀스 시작
                Task {
                    await runFullCalibrationSequence(totalPoints: pts.count, targets: pts)
                }
            }
            .onDisappear {
                UIApplication.shared.isIdleTimerDisabled = false
            }
            .onChange(of: vm.gazePoint) {
                // 데이터 수집 로직
                guard isCollecting,
                      currentIndex >= 0,
                      currentIndex < collectedGazePoints.count
                else { return }
                
                collectedGazePoints[currentIndex].append(vm.gazePoint)
            }
        }
    }
    
    // MARK: - Async Logic (순차 실행)
    
    // 전체 과정을 관리하는 메인 함수
    private func runFullCalibrationSequence(totalPoints: Int, targets: [CGPoint]) async {
        
        // 1. 시작 카운트다운 (3 -> 2 -> 1)
        for i in (1...3).reversed() {
            startCountdown = i
            try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1초 대기
        }
        
        // 2. 캘리브레이션 시작
        withAnimation {
            isStarted = true
        }
        
        // 3. 각 점마다 이동 -> 대기 -> 수집(카운트다운) 반복
        for i in 0..<totalPoints {
            currentIndex = i
            isCollecting = false
            
            // 점 이동 후 정착 시간 (0.5초)
            // 눈이 점을 찾아가는 시간을 줍니다.
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5초
            
            // 데이터 수집 시작 & 점 내부 카운트다운 (2초간)
            isCollecting = true
            
            // 2초 -> 1초 카운트다운
            for t in (1...2).reversed() {
                dotCountdown = t
                try? await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1초씩 대기
            }
            
            isCollecting = false
        }
        
        // 4. 모든 과정 종료
        finishCalibration(targets: targets)
    }
    
    // 완료 처리
    private func finishCalibration(targets: [CGPoint]) {
        vm.isCalibrating = false
        vm.isDoneCalibration = true
        vm.processAndStoreCalibration(targets: targets, samples: collectedGazePoints)
    }
    
    private var descriptionText: some View {
        Text("움직이는 점을 따라 응시해주세요")
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
    }
}
