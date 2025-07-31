//
//  PreeButton.swift
//  Pree
//
//  Created by KimDogyung on 7/27/25.
//

import SwiftUI

struct PrimaryButton: View {
    
    var title: String?
    
    var body: some View {
        Button(
            action: {},
            label: {
                Text(title ?? "")
            }
        )
        .buttonStyle(BlueRoundedButtonStyle())
    }
}




struct BlueRoundedButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.pretendardSemiBold(size: 20))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)   
            .padding(.vertical, 14)
            .background(Color.primary)
            .cornerRadius(20)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
