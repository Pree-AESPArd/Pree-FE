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

final class PresentaionListViewModel: ObservableObject {
    @Published var ptTitle: String = "협체발표"
    @Published var practiceCount: Int = 5
    @Published var scores: [Double] = [70, 80, 60, 90, 55]
    
    @Published var option: MoreOption? = nil
    @Published var showDeleteMode: Bool = false
    @Published var showEditMode: Bool = false
}
