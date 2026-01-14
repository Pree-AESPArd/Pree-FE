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
    
    @Published var filterMode: FilterMode = .recentMode
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
        try? await presentationRepository.fetchPresentations()
    }
}
