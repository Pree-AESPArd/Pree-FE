//
//  CompleteView.swift
//  Pree
//
//  Created by KimDogyung on 8/17/25.
//

import SwiftUI


struct CompleteView: View {
    var body: some View {
        VStack(spacing: 20) {
            
            CircularLoadingView()
                .frame(width: 46, height: 46)
            
            waitngText
            
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





#Preview {
    CompleteView()
}
