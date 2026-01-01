//
//  DeviceDimensionHelper.swift
//  Pree
//
//  Created by KimDogyung on 12/29/25.
//

import UIKit

struct DeviceDimensionHelper {
    
    // 기기의 물리적 가로, 세로 길이 (단위: 미터)
    static func getPhysicalSize() -> CGSize {
        let modelName = UIDevice.modelName
        
        switch modelName {
            
        // MARK: - iPhone 17 Series & Air
        case "iPhone18,2": // iPhone 17 Pro Max
            return CGSize(width: 0.0780, height: 0.1634)
            
        case "iPhone18,1": // iPhone 17 Pro
            return CGSize(width: 0.0719, height: 0.1500)
            
        case "iPhone18,3": // iPhone 17
            return CGSize(width: 0.0715, height: 0.1496)
            
        case "iPhone18,4": // iPhone Air
            return CGSize(width: 0.0747, height: 0.1562)

            
        // MARK: - iPhone 16 Series
        case "iPhone17,2": // iPhone 16 Pro Max
            return CGSize(width: 0.0776, height: 0.1630)
            
        case "iPhone17,1": // iPhone 16 Pro
            return CGSize(width: 0.0715, height: 0.1496)
            
        case "iPhone17,4": // iPhone 16 Plus
            return CGSize(width: 0.0778, height: 0.1609)
            
        case "iPhone17,3": // iPhone 16
            return CGSize(width: 0.0716, height: 0.1476)
            
        case "iPhone17,5": // iPhone 16e
            return CGSize(width: 0.0716, height: 0.1476)
            
            
        // MARK: - iPhone 15 Series
        case "iPhone16,2": // iPhone 15 Pro Max
            return CGSize(width: 0.0767, height: 0.1599)
            
        case "iPhone16,1": // iPhone 15 Pro
            return CGSize(width: 0.0706, height: 0.1466)
            
        case "iPhone15,5": // iPhone 15 Plus
            return CGSize(width: 0.0778, height: 0.1609)
            
        case "iPhone15,4": // iPhone 15
            return CGSize(width: 0.0716, height: 0.1476)
            
            
        // MARK: - iPhone 14 Series
        case "iPhone15,3": // iPhone 14 Pro Max
            return CGSize(width: 0.0776, height: 0.1607)
            
        case "iPhone15,2": // iPhone 14 Pro
            return CGSize(width: 0.0715, height: 0.1475)
            
        case "iPhone14,8": // iPhone 14 Plus
            return CGSize(width: 0.0781, height: 0.1608)
            
        case "iPhone14,7": // iPhone 14
            return CGSize(width: 0.0715, height: 0.1467)
            
            
        // MARK: - iPhone 13 Series
        case "iPhone14,3": // iPhone 13 Pro Max
            return CGSize(width: 0.0781, height: 0.1608)
            
        case "iPhone14,2": // iPhone 13 Pro
            return CGSize(width: 0.0715, height: 0.1467)
            
        case "iPhone14,5": // iPhone 13
            return CGSize(width: 0.0715, height: 0.1467)
            
        case "iPhone14,4": // iPhone 13 Mini
            return CGSize(width: 0.0642, height: 0.1315)
            
            
        // MARK: - iPhone 12 Series
        case "iPhone13,4": // iPhone 12 Pro Max
            return CGSize(width: 0.0781, height: 0.1608)
            
        case "iPhone13,3": // iPhone 12 Pro
            return CGSize(width: 0.0715, height: 0.1467)
            
        case "iPhone13,2": // iPhone 12
            return CGSize(width: 0.0715, height: 0.1467)
            
        case "iPhone13,1": // iPhone 12 Mini
            return CGSize(width: 0.0642, height: 0.1315)
            
            
        // MARK: - iPhone 11 Series
        case "iPhone12,5": // iPhone 11 Pro Max
            return CGSize(width: 0.0778, height: 0.1580)
            
        case "iPhone12,3": // iPhone 11 Pro
            return CGSize(width: 0.0714, height: 0.1440)
            
        case "iPhone12,1": // iPhone 11
            return CGSize(width: 0.0757, height: 0.1509)
            
            
        // MARK: - X / XS / XR Series
        case "iPhone11,6", "iPhone11,4": // iPhone XS Max
            return CGSize(width: 0.0774, height: 0.1575)
            
        case "iPhone11,2": // iPhone XS
            return CGSize(width: 0.0709, height: 0.1436)
            
        case "iPhone11,8": // iPhone XR
            return CGSize(width: 0.0757, height: 0.1509)
            
        case "iPhone10,3", "iPhone10,6": // iPhone X
            return CGSize(width: 0.0709, height: 0.1436)
            
            
        // MARK: - SE Series
        case "iPhone14,6": // iPhone SE (3rd generation)
            return CGSize(width: 0.0673, height: 0.1384)
            
        case "iPhone12,8": // iPhone SE (2nd generation)
            return CGSize(width: 0.0673, height: 0.1384)
            
            
        // MARK: - Default (Unknown Device)
        default:
            // 알 수 없는 기기일 경우, 가장 일반적인 크기(15/16 Pro급)를 기본값으로 사용
            //print("⚠️ 알 수 없는 기기 모델: \(modelName). 기본값을 사용합니다.")
            return CGSize(width: 0.0715, height: 0.1496)
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
