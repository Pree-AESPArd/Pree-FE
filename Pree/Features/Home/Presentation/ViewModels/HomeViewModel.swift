//
//  HomeViewModel.swift
//  Pree
//
//  Created by 이유현 on 7/31/25.
//

import Foundation
import Combine
import SwiftUI

enum FilterMode {
    case recentMode
    case bookmarkMode
}

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var presentations: [Presentation] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var filterMode: FilterMode = .recentMode {
        didSet {
            // 모드가 바뀌면 자동으로 목록 갱신 요청
            Task { await fetchList() }
        }
    }
    @Published var showDeleteMode: Bool = false
    
    @Published var userName: String = "게스트"
    @Published var percentages: [CGFloat] = [0, 0, 0, 0, 0, 0]
    @Published var presentationListCount: Int = 1
    
    @Published var score: Double = 0.2
    
    @Published var searchText: String = ""
    
    private let presentationRepository: PresentationRepositoryProtocol
    private let getLatestProjectScoresUseCase: GetLatestProjectScoresUseCaseProtocol
    private let searchProjectsUseCase: SearchProjectsUseCaseProtocol
    private let deletePresentationUseCase: DeletePresentationUseCaseProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(presentationRepository: PresentationRepositoryProtocol,
         getLatestProjectScoresUseCase: GetLatestProjectScoresUseCase,
         searchProjectsUseCase: SearchProjectsUseCaseProtocol,
         deletePresentationUseCase: DeletePresentationUseCaseProtocol
    ) {
        self.presentationRepository = presentationRepository
        self.getLatestProjectScoresUseCase = getLatestProjectScoresUseCase
        self.searchProjectsUseCase = searchProjectsUseCase
        self.deletePresentationUseCase = deletePresentationUseCase
        
        if let repo = presentationRepository as? PresentationRepository {
            repo.presentationsPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.presentations, on: self)
                .store(in: &cancellables)
        }
        
        // 검색 로직
        $searchText
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main) // 0.5초 대기
            .removeDuplicates()
            .sink { [weak self] text in
                guard let self = self else { return }
                Task {
                    if text.isEmpty {
                        // 검색어가 비면 원래 리스트(필터 모드)로 복구
                        await self.fetchList()
                    } else {
                        // 검색 실행
                        await self.performSearch(query: text)
                    }
                }
            }
            .store(in: &cancellables)
        
        // 앱 켤 때 최초 1회 로딩
        Task { await fetchList() }
    }
    
    
    @MainActor
    func fetchList() async {
        isLoading = true
        
        // 현재 filterMode에 따라 서버에 보낼 문자열 결정
        let sortOptionString: String
        switch filterMode {
        case .recentMode:
            sortOptionString = "latest"
        case .bookmarkMode:
            sortOptionString = "favorite"
        }
        
        do {
            try await presentationRepository.fetchPresentations(sortOption: sortOptionString)
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleFavorite(presentation: Presentation) {
        Task {
            do {
                // ViewModel에서는 Repository만 호출하면 끝 (UI 갱신은 Combine이 알아서 함)
                try await presentationRepository.toggleFavorite(projectId: presentation.id)
            } catch {
                // 에러 발생 시 처리 (Repository가 롤백하므로 Toast 정도만 띄워주면 됨)
                self.errorMessage = "즐겨찾기 변경 실패: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchLatestScores() async {
        do {
            let scores = try await getLatestProjectScoresUseCase.execute()
            
            // 2. BarGraphView의 라벨 순서에 맞춰서 배열 생성
            // 순서: ["발표 시간", "말 빠르기", "음성 크기", "발화 지연", "공백 횟수", "시선 처리"]
            let newPercentages: [CGFloat] = [
                CGFloat(scores.durationScore),    // 발표 시간
                CGFloat(scores.wpmScore),         // 말 빠르기
                CGFloat(scores.dbScore),          // 음성 크기
                CGFloat(scores.fillerScore),      // 발화 지연
                CGFloat(scores.silenceScore),     // 공백 횟수
                CGFloat(scores.eyeTrackingScore)  // 시선 처리
            ]
            
            // 3. UI 업데이트
            withAnimation {
                self.percentages = newPercentages
            }
            
        } catch {
            // 에러 발생 시 0으로 초기화하거나 기존 값 유지
        }
    }
    
    
    func performSearch(query: String) async {
        isLoading = true
        do {
            let results = try await searchProjectsUseCase.execute(query: query)
            self.presentations = results
        } catch {
            print("❌ 검색 실패: \(error)")
            // 필요 시 에러 메시지 표시
        }
        isLoading = false
    }
    
    
    func deleteItem(presentation: Presentation) {
        Task {
            do {
                // 1. 서버 요청
                try await deletePresentationUseCase.execute(id: presentation.id)
                
                // 2. 로컬 리스트에서 즉시 제거 (UI 반응성 향상)
                if let index = self.presentations.firstIndex(where: { $0.id == presentation.id }) {
                    withAnimation {
                        self.presentations.remove(at: index)
                    }
                }
                
                // 3. 최신 점수 그래프 등 다른 정보도 갱신 호출
                await fetchLatestScores()
                
            } catch {
                self.errorMessage = "삭제 실패: \(error.localizedDescription)"
            }
        }
    }
    
}
