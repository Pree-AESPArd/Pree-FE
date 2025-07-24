//
//  File.swift
//  AllIn
//
//  Created by KimDogyung on 7/19/25.
//

import SwiftUI

enum AppColor {
    static let primary: Color = Color(hex: "#487EE3")
    static let secondary: Color = Color(hex: "#D2D6DA")
    static let alertRed: Color = Color(hex: "#1A1E27")
    static let mainBackground: Color = Color(hex: "#F2F4F6")
    static let cardBackground: Color = Color(hex: "#FFFFFF")
    static let textPrimary: Color = Color(hex: "#1A1E27")
    static let textSecondary: Color = Color("TextSecondary")
    static let textRed: Color = Color(hex: "#1A1E27")
}


extension Color {
    static let primary = AppColor.primary
    static let secondary = AppColor.secondary
    static let alertRed = AppColor.alertRed
    static let mainBackground = AppColor.mainBackground
    static let cardBackground = AppColor.cardBackground
    static let textPrimary = AppColor.textPrimary
    static let textRed = AppColor.textRed
}
