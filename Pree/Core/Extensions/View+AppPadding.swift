//
//  View+AppPadding.swift
//  AllIn
//
//  Created by KimDogyung on 7/18/25.
//

import SwiftUI

struct AppPadding: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
    }
}

extension View {
    func appPadding() -> some View {
        self.modifier(AppPadding())
    }
}
