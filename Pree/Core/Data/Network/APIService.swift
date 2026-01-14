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
    
    
    func fetchPresentations() async throws -> [PresentationDTO] {
        let endpoint = "\(Config.baseURL)/projects/"
        
        // 저장된 UUID 꺼내기 (없으면 에러 처리)
        guard let userId = UserStorage.shared.getUUID() else {
            print("❌ [Network] 유저 ID가 없습니다.")
            throw URLError(.userAuthenticationRequired)
        }
        
        // 인증 헤더 (Firebase 토큰 - 기존에 있다면 유지)
        guard let idToken = try await Auth.auth().currentUser?.getIDToken() else {
            throw URLError(.userAuthenticationRequired)
        }
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(idToken)",
            "Content-Type": "application/json"
        ]
        
        // 쿼리 파라미터 설정
        let parameters: [String: Any] = [
            "user_id": userId
        ]
        
        let dataRequest = AF.request(
            endpoint,
            method: .get,
            parameters: parameters,
            encoding: URLEncoding.default,
            headers: headers
        )
            .validate(statusCode: 200..<300)
        
        do {
            let dtos = try await dataRequest.serializingDecodable([PresentationDTO].self).value
            return dtos
        } catch {
            print("❌ [APIService] 리스트 요청 실패: \(error.localizedDescription)")
           
            throw error
        }
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
