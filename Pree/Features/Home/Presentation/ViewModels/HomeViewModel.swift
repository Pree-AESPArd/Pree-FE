//
//  HomeViewModel.swift
//  Pree
//
//  Created by 이유현 on 7/31/25.
//

import Foundation

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
    
    @Published var userName: String = "규희"
    @Published var percentages: [CGFloat] = [82, 89, 50, 32, 100, 30]
    @Published var percentagesZero: [CGFloat] = [0, 0, 0, 0, 0, 0]
    @Published var presentationListCount: Int = 1
    
    @Published var score: Double = 0.2
    
    private let fetchPresentationsUseCase: FetchPresentationsUseCase
    
    init(fetchPresentationsUseCase: FetchPresentationsUseCase) {
        self.fetchPresentationsUseCase = fetchPresentationsUseCase
    }
    
    
    @MainActor
    func loadPresentations() async {
        isLoading = true
        errorMessage = nil
        
        do {
            self.presentations = try await fetchPresentationsUseCase.execute()
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
