//
//  PreeButton.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI

struct PrimaryButton: View {
    
    let title: String?
    let action: ()->Void
    
    var isActive: Bool = true
    
    var body: some View {
        Button(
            action: {
                if isActive { // 안전장치
                    action()
                }
            },
            label: {
                Text(title ?? "")
            }
        )
        .buttonStyle(BlueRoundedButtonStyle(isActive: isActive))
        .disabled(!isActive)
    }
}




struct BlueRoundedButtonStyle: ButtonStyle {
    
    var isActive: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pretendardSemiBold(size: 20))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(isActive ? Color.primary : Color(hex: "#D2D3D5"))
            .cornerRadius(20)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
