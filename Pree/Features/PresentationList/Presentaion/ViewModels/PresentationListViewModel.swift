//
//  PresentaionListViewModel.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import Foundation

enum MoreOption {
    case defalut
    case editName
    case deleteAll
}

final class PresentationListViewModel: ObservableObject {
    @Published var presentation: Presentation
    
    @Published var ptTitle: String = "협체발표"
    @Published var practiceCount: Int = 5
    @Published var scores: [Double]
    
    @Published var option: MoreOption? = nil
    @Published var showDeleteMode: Bool = false
    @Published var showEditMode: Bool = false
    
    private let getRecentScoresUseCase: GetRecentScoresUseCaseProtocol
    
    init(presentation: Presentation, getRecentScoresUseCase: GetRecentScoresUseCaseProtocol) {
        self.presentation = presentation
        self.getRecentScoresUseCase = getRecentScoresUseCase
        
        self.ptTitle = presentation.presentationName
        self.practiceCount = presentation.totalPractices
        
        // 초기 로딩 시 더미 데이터 혹은 빈 배열
        self.scores = []
    }
    
    
    @MainActor
    func fetchGraphData() async {
        do {
            let fetchedScores = try await getRecentScoresUseCase.execute(presentationId: presentation.id)
            
            if fetchedScores.isEmpty {
                self.scores = []
            } else {
                self.scores = fetchedScores
            }
            
        } catch {
            print("❌ 그래프 데이터 로드 실패: \(error)")
            // 에러 시 UI 처리 (ex: scores = [])
        }
    }
    
}
