//
//  HomeViewModel.swift
//  Pree
//
//  Created by 이유현 on 7/31/25.
//

import Foundation
import Combine

enum FilterMode {
    case recentMode
    case bookmarkMode
}

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
    @Published var percentages: [CGFloat] = [82, 89, 50, 32, 100, 30]
    @Published var percentagesZero: [CGFloat] = [0, 0, 0, 0, 0, 0]
    @Published var presentationListCount: Int = 1
    
    @Published var score: Double = 0.2
    
    private let presentationRepository: PresentationRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(presentationRepository: PresentationRepositoryProtocol) {
        self.presentationRepository = presentationRepository
        
        if let repo = presentationRepository as? PresentationRepository {
            repo.presentationsPublisher
                .receive(on: DispatchQueue.main)
                .assign(to: \.presentations, on: self)
                .store(in: &cancellables)
        }
        
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
    
}
