//
//  DeviceDimensionHelper.swift
//  Pree
//
//  Created by KimDogyung on 12/29/25.
//

import UIKit

struct DeviceDimensionHelper {
    
    // 기기의 물리적 가로, 세로 길이 (단위: 미터)
    // 최신 아이폰 모델들의 대략적인 화면 크기입니다.
    // 정확도를 높이려면 더 많은 모델을 추가해야 합니다.
    static func getPhysicalSize() -> CGSize {
        let modelName = UIDevice.modelName
        
        switch modelName {
        
        // iPhone 16
        case "iPhone17,3":
            return CGSize(width: 0.0716, height: 0.1476)
            
        // iPhone 14 Pro, 15 Pro, 16 Pro (6.1 inch)
        case "iPhone15,2", "iPhone16,1", "iPhone17,1":
            return CGSize(width: 0.0715, height: 0.1475)
            
        // iPhone 14 Pro Max, 15 Pro Max (6.7 inch)
        case "iPhone15,3", "iPhone16,2":
            return CGSize(width: 0.0776, height: 0.1607)
            
        // iPhone 13, 14 (6.1 inch)
        case "iPhone14,5", "iPhone14,7":
            return CGSize(width: 0.0715, height: 0.1467)
            
        // 기본값 (iPhone 14 Pro 기준) - 알 수 없는 기기일 때 사용
        default:
            return CGSize(width: 0.0715, height: 0.1475)
        }
    }
}

// 기기 모델명을 가져오기 위한 확장
extension UIDevice {
    static var modelName: String {
        // 1. 시스템 정보를 담을 구조체(통)를 준비
        var systemInfo = utsname()
        
        // 2. C언어 시스템 함수(uname)를 호출해서 기계 정보를 가져옴
        // 여기서 systemInfo.machine에 "iPhone15,2" 같은 암호가 채워짐
        uname(&systemInfo)
        
        // 3. 기계어(바이트)로 된 정보를 우리가 읽을 수 있는 문자열로 변환 (Mirror 사용)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        
        // 4. 바이트 하나하나를 문자로 합침
        return machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
    }
}
