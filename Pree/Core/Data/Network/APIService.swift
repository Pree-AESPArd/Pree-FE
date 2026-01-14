//
//  APIClient.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation
import Alamofire
import FirebaseAuth

struct APIService: APIServiceProtocol {
    
    private let url = Config.baseURL
    
    
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
    
    func createPresentation(request: CreatePresentationRequestDTO) async throws -> PresentationDTO {
        let endpoint = "\(url)/projects/"
        
        // 인증 헤더 (Firebase 사용 시 필수)
        // 게스트 로그인이라도 Firebase에서 발급한 ID 토큰을 보내야 서버에서 누군지 식별
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
            print("❌ 유효한 유저 토큰이 없습니다.")
            throw URLError(.userAuthenticationRequired)
        }
        
        let headers: HTTPHeaders = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(idToken)"
        ]
        
        let dataRequest = AF.request(
            endpoint,
            method: .post,
            parameters: request,
            encoder: JSONParameterEncoder.default,
            headers: headers
        )
            .validate(statusCode: 200..<300)
        
        // 3. 응답 처리 및 디버깅
        do {
            // 여기서 통신 및 디코딩을 시도합니다.
            let result = try await dataRequest.serializingDecodable(PresentationDTO.self).value
            print("✅ [Network] 발표 생성 성공!")
            return result
            
        } catch {
            // 4. 에러 발생 시 서버가 보낸 에러 메시지(Body) 확인
            // 수정 포인트: .result.success 대신 .result.get() 사용
            if let data = try? await dataRequest.serializingData().result.get() {
                let errorBody = String(data: data, encoding: .utf8) ?? "알 수 없는 인코딩"
                print("❌ [Network] 서버 에러 본문: \(errorBody)")
            }
            
            print("❌ [Network] 요청 실패: \(error.localizedDescription)")
            throw error
        }
    }
    
}
