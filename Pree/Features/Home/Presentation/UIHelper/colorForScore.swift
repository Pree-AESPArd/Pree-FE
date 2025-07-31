//
//  File.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import Foundation
import UIKit

func colorForScore(_ value: Double) -> UIColor {
    if value <= 0.6 {
        return UIColor(red: 1, green: 0, blue: 0, alpha: 1) // 빨간색
    } else if value <= 0.8 {
        return UIColor(red: 1, green: 0.717, blue: 0, alpha: 1) // 주황색
    } else {
        return UIColor(red: 0, green: 0.75, blue: 0.2, alpha: 1) // 초록색
    }
}
