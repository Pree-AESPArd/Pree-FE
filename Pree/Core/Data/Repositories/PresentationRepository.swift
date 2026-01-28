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
    func fetchPresentations(sortOption: String = "latest") async throws {
        let dtos = try await apiService.fetchPresentations(sortOption: sortOption)
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
    
    func toggleFavorite(projectId: String) async throws {
        // 1. 현재 리스트 가져오기
        var currentList = presentationsSubject.value
        
        // 2. 해당 프로젝트 찾기 (Index 찾기)
        guard let index = currentList.firstIndex(where: { $0.id == projectId }) else { return }
        
        // 3. [Optimistic Update] 서버 통신 전에 로컬 데이터 먼저 뒤집기
        let oldItem = currentList[index]
        let newItem = oldItem.updateFavorite(!oldItem.isFavorite) // 토글
        
        currentList[index] = newItem
        presentationsSubject.send(currentList) // UI 즉시 갱신
        
        // 4. 서버 요청 보내기 (백그라운드)
        do {
            let serverResult = try await apiService.toggleFavorite(projectId: projectId)
            
            // (선택) 서버 결과가 로컬 상태와 다르면 다시 맞춰줌 (동기화 보장)
            if newItem.isFavorite != serverResult {
                var fixedList = presentationsSubject.value
                if let fixIndex = fixedList.firstIndex(where: { $0.id == projectId }) {
                    fixedList[fixIndex] = oldItem.updateFavorite(serverResult)
                    presentationsSubject.send(fixedList)
                }
            }
            
        } catch {
            // 5. 실패 시 원상복구 (Rollback)
            print("❌ 즐겨찾기 실패 -> 롤백 수행")
            var rollbackList = presentationsSubject.value
            if let rollbackIndex = rollbackList.firstIndex(where: { $0.id == projectId }) {
                rollbackList[rollbackIndex] = oldItem // 원래대로 되돌림
                presentationsSubject.send(rollbackList)
            }
            throw error
        }
    }
    
    
    func fetchLatestProjectScores() async throws -> ProjectAverageScores {
        let dto = try await apiService.fetchLatestAverageScores()
        return dto.toDomain()
    }
    
    
    func searchProjects(query: String) async throws -> [Presentation] {
        let dtos = try await apiService.searchProjects(query: query)
        
        return dtos.map { PresentationMapper.toEntity($0) }
    }
    
    func deletePresentation(id: String) async throws {
        try await apiService.deleteProject(projectId: id)
    }
    
}
