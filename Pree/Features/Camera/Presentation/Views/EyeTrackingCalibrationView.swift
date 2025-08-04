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

    // 총 9개의 포인트를 담을 배열. GeometryReader 안에서 화면 크기에 맞춰 계산합니다.
    private func positions(in size: CGSize) -> [CGPoint] {
        let w = size.width
        let h = size.height
        return [
            CGPoint(x: 16,       y: 0),
            CGPoint(x: w/2,      y: 0),
            CGPoint(x: w - 16,   y: 0),
            CGPoint(x: w - 16,   y: h/2),
            CGPoint(x: w - 16,   y: h - 12),
            CGPoint(x: w/2,      y: h - 12),
            CGPoint(x: 16,       y: h - 12),
            CGPoint(x: 16,       y: h/2),
            CGPoint(x: w/2,      y: h/2),
    
        ]
    }
    
    
    var body: some View {
        GeometryReader { geo in
            let pts = positions(in: geo.size)
            ZStack {
                Color.black
                    .opacity(1.0)
                    .edgesIgnoringSafeArea(.all)
                
                
                
                // currentIndex 가 유효 범위일 때만 하나의 원을 찍어준다
                if currentIndex >= 0 && currentIndex < pts.count {
                    let pt = positions(in: geo.size)[currentIndex]
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 20, height: 20)
                        .position(pt)
                        .animation(.easeInOut, value: currentIndex)
                }
                
                
            }
            .onAppear {
                collectedGazePoints = Array(repeating: [], count: pts.count)
                showNext(at: 0, total: pts.count)
                
            }
            .onChange(of: vm.gazePoint) {
                guard currentIndex >= 0,
                      currentIndex < collectedGazePoints.count
                else { return }
                collectedGazePoints[currentIndex].append(vm.gazePoint)
//                print("Bucket[\(currentIndex)] now has \(collectedGazePoints[currentIndex].count) points")
            }
        }
    }
    
    @State var gazing: Bool = false
    
    // circle 애니메이션 제어
    private func showNext(at idx: Int, total: Int) {
        guard idx < total else {
            vm.isCalibrating.toggle()
            print(collectedGazePoints)
            return
        }
        
        currentIndex = idx
        gazing.toggle()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            gazing.toggle()
            // 이전 원은 사라지고 다음 원만 보인다
            showNext(at: idx + 1, total: total)
        }
    }
    
    private func getCurrentGazingPoint() {
        var currentPoints: [CGPoint] = []
        
        while gazing {
            currentPoints.append(vm.gazePoint)
        }
        print(currentPoints)
    }
    
    
    private var descriptionText: some View {
        Text("움직이는 점을 따라 응시해주세요")
            .font(.pretendardSemiBold(size: 14))
            .foregroundStyle(.white)
    }
    
    
}



#Preview {
//    EyeTrackingCalibrationView()
}
