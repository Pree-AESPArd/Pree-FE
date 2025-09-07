//
//  APIClient.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation
import Alamofire

struct APIService {
    
    let url = "testUrl"
    
    
    func fetchPresentations() async throws -> [Presentation] {
        
        let response = await AF.request(url)
            .serializingDecodable([Presentation].self)
            .response // 상태 코드, 헤더 등도 같이 확인해야 할 때
            // or .value -> 깔끔하게 await 후 데이터만 받고 싶을 때
        
        switch response.result {
        case .success(let presentations):
            return presentations
        case .failure(let error):
            throw error
        }
    }
    
}
