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
        
//        let response = await AF.request(url)
//            .validate(statusCode: 200..<300)
//            .serializingDecodable([Presentation].self)
//            .response // 상태 코드, 헤더 등도 같이 확인해야 할 때
//        // or .value -> 깔끔하게 await 후 데이터만 받고 싶을 때
//        
//        switch response.result {
//        case .success(let presentations):
//            return presentations
//        case .failure(let error):
//            throw error
//        }
        
        try await AF.request(url)
            .validate(statusCode: 200..<300)
            .serializingDecodable([Presentation].self)
            .value
    }
    
    func createPresentation(createPresentationRequest presentation: CreatePresentationRequest) async throws -> ResponseForNewPresentation {
        
        // HTTP Headers 설정 (필요한 경우)
        // 예를 들어, 인증 토큰을 전달할 때 사용
        let headers: HTTPHeaders = [
            "Accept": "application/json",
            "Content-Type": "application/json",
            // "Authorization": "Bearer \(yourAuthToken)"
        ]
        
        // Alamofire를 사용하여 POST 요청을 보냅니다.
        // 'requestData'는 인코딩되어 HTTP Body에 담깁니다.
        // '.validate()'는 응답 코드가 200-299 사이가 아닐 경우 에러를 발생시킵니다.
        let response = try await AF.request("\(url)/presentations",
                             method: .post,
                             parameters: presentation,
                             encoder: JSONParameterEncoder.default,
                             headers: headers)
        .validate(statusCode: 200..<300)
        .serializingDecodable(ResponseForNewPresentation.self)
        .value
        
        
        return response
        
    }
    
}
