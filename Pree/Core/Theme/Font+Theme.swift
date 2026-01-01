//
//  Font+Theme.swift
//  AllIn
//
//  Created by KimDogyung on 7/19/25.
//

import SwiftUI

enum AppFont {
    
    enum CustomWeight: String {
        case bold    = "Bold"
        case semiBold = "SemiBold"
        case medium  = "Medium"
        case regular = "Regular"
    }
    
    static func custom(_ size: CGFloat, weight: CustomWeight = .regular) -> Font {
        Font.custom("Pretendard-\(weight.rawValue)", size: size)
    }
}


extension View {
    func title1(_ size: CGFloat = 30) -> some View {
        self.font(AppFont.custom(size, weight: .semiBold))
    }
    
    func title2(_ size: CGFloat = 25) -> some View {
        self.font(AppFont.custom(size, weight: .semiBold))
    }
    
    func title3(_ size: CGFloat = 22) -> some View {
        self.font(AppFont.custom(size, weight: .semiBold))
    }
    
    func title4(_ size: CGFloat = 20) -> some View {
        self.font(AppFont.custom(size, weight: .semiBold))
    }
    
    func subtitle1(_ size: CGFloat = 17) -> some View {
        self.font(AppFont.custom(size, weight: .semiBold))
    }
    
    func subtitle2(_ size: CGFloat = 16) -> some View {
        self.font(AppFont.custom(size, weight: .medium))
    }
    
    func body1(_ size: CGFloat = 15) -> some View {
        self.font(AppFont.custom(size, weight: .medium))
    }
    
    func body2(_ size: CGFloat = 13) -> some View {
        self.font(AppFont.custom(size, weight: .medium))
    }
    
}
