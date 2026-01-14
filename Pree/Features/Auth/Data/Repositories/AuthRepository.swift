//
//  AuthRepository.swift
//  Pree
//
//  Created by KimDogyung on 1/7/26.
//

import Foundation
import Alamofire

class AuthRepository {
    static let shared = AuthRepository()
    
    // 서버로 로그인 정보를 전송하는 함수
    func sendGuestLogin(request: GuestLoginRequest) async throws {
        
        // 1. URL 조합
        let url = Config.baseURL + "/users/login"
        
        // 2. Alamofire 요청 (Async/Await)
        // .serializingDecodable() 안쓰고 성공 여부(Status Code 200)만 확인하는 로직으로 짬
        let request = AF.request(url,
                                 method: .post,
                                 parameters: request,
                                 encoder: JSONParameterEncoder.default)
            .validate() // 200~299 상태코드가 아니면 에러로 간주
        
        
        do {
            let response = try await request.serializingDecodable(UserResponseDTO.self).value
            
            // 💾 여기서 UUID를 저장
            UserStorage.shared.saveUUID(response.id)
            
            print("✅ [AuthRepo] 로그인 및 UUID 저장 성공")
        } catch {
            print("❌ [AuthRepo] 로그인 실패 또는 응답 파싱 실패")
            throw error
        }
    }
}
