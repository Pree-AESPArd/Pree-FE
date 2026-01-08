//
//  Config.swift
//  Pree
//
//  Created by KimDogyung on 1/6/26.
//

import Foundation

struct Config {
    
    // Info.plist에서 값을 읽어오는 헬퍼 함수
    private static func infoDictValue(forKey key: String) -> String {
        guard let value = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            fatalError("plist에서 \(key)를 찾을 수 없습니다.")
        }
        return value
    }
    
    // ⭐️ 최종 Base URL 조합
    static var baseURL: String {
        let protocolType = infoDictValue(forKey: "ServerProtocol") // http or https
        let host = infoDictValue(forKey: "ServerHost")            
        
        // xcconfig의 특성상 //가 주석처리 되므로 여기서 합쳐줍니다.
        return "\(protocolType)://\(host)"
    }
}
