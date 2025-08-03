//
//  ShadowModifier.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import Foundation
import SwiftUI

struct ShadowModifier: ViewModifier {
    
    func body(content: Content) -> some View {
            content
            .shadow(
                color: Color(red: 0, green: 0.271, blue: 0.91).opacity(0.1),
                radius: 15,
                x: 0,
                y: 0
            )
        }
}

extension View {
    func applyShadowStyle() -> some View {
            self.modifier(ShadowModifier())
        }
}
