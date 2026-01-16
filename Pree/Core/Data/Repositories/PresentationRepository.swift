//
//  PresentationRepositoryImpl.swift
//  Pree
//
//  Created by KimDogyung on 9/7/25.
//

import Foundation
import Combine

// reactive 패턴 사용
struct PresentationRepository: PresentationRepositoryProtocol {
    
    let apiService: APIServiceProtocol
    
    // 메모리 캐시 역할 및 스트림 생성
    // 현재 리스트 상태를 가지고 있으며, 변경 시 구독자들에게 알림
    private let presentationsSubject = CurrentValueSubject<[Presentation], Never>([])
    
    // 외부에서 구독할 수 있는 Publisher (읽기 전용)
    var presentationsPublisher: AnyPublisher<[Presentation], Never> {
        return presentationsSubject.eraseToAnyPublisher()
    }
    
    // 서버에서 리스트 가져와서 스트림에 쏘기
    func fetchPresentations() async throws {
        let dtos = try await apiService.fetchPresentations()
        let entities = dtos.map { PresentationMapper.toEntity($0) }
        
        // 받아온 데이터를 스트림에 방출 (구독자들 UI 업데이트됨)
        self.presentationsSubject.send(entities)
    }
    
    // 생성 후 로컬 리스트에 '끼워넣기' (Optimistic Update or Post-Update)
    func createNewPresentation(request: CreatePresentationRequest) async throws -> Presentation {
        let dto = CreatePresentationRequestMapper.toDTO(request)
        let responseDTO = try await apiService.createPresentation(request: dto)
        let newEntity = PresentationMapper.toEntity(responseDTO)
        
        // 서버에서 전체를 다시 불러오지 않고, 현재 리스트에 새것만 추가해서 방출!
        var currentList = presentationsSubject.value
        currentList.insert(newEntity, at: 0) // 최신순이면 맨 앞에
        presentationsSubject.send(currentList)
        
        return newEntity
    }
    
}
