//
//  CalibrationView.swift
//  Pree
//
//  Created by KimDogyung on 8/3/25.
//


import SwiftUI

struct EyeTrackingCalibrationView: View {
    
    @State private var currentIndex: Int = -1
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
            ZStack {
                Color.black
                    .opacity(1.0)
                    .edgesIgnoringSafeArea(.all)
                
                
                
                // currentIndex 가 유효 범위일 때만 하나의 원을 찍어준다
                if currentIndex >= 0 && currentIndex < positions(in: geo.size).count {
                    let pt = positions(in: geo.size)[currentIndex]
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 20, height: 20)
                        .position(pt)
                        .animation(.easeInOut, value: currentIndex)
                }
                
                
            }
            .onAppear {
                showNext(at: 0, total: positions(in: geo.size).count)
            }
        }
    }
    
    private func showNext(at idx: Int, total: Int) {
        guard idx < total else { return }
        currentIndex = idx
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // 이전 원은 사라지고 다음 원만 보인다
            showNext(at: idx + 1, total: total)
        }
    }
    
    private var descriptionText: some View {
        Text("움직이는 점을 따라 응시해주세요")
            .font(.pretendardSemiBold(size: 14))
            .foregroundStyle(.white)
    }
    
    
}



#Preview {
    EyeTrackingCalibrationView()
}
