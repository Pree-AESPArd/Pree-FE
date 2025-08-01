//
//  View+CornerRadius.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadiusCustom(_ radius: CGFloat, corners: UIRectCorner? = nil) -> some View {
        let cornerRadius = corners ?? .allCorners
        return clipShape(RoundedCorner(radius: radius, corners: cornerRadius))
    }
}
