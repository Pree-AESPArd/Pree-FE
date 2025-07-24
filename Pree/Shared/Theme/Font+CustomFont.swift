//
//  Font+CustomFont.swift
//  TossDemo
//
//  Created by USER on 1/7/25.
//

import SwiftUI

extension Font {
    static func pretendardBold(size: CGFloat) -> Font {
        .custom("Pretendard-Bold", size: size)
    }

    static func pretendardSemiBold(size: CGFloat) -> Font {
        .custom("Pretendard-SemiBold", size: size)
    }

    static func pretendardMedium(size: CGFloat) -> Font {
        .custom("Pretendard-Medium", size: size)
    }

    static func pretendardRegular(size: CGFloat) -> Font {
        .custom("Pretendard-Regular", size: size)
    }

    static func tossFace(size: CGFloat) -> Font {
        .custom("TossFaceFontMac", size: size)
    }
}
