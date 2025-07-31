//
//  HomeViewModel.swift
//  Pree
//
//  Created by 이유현 on 7/31/25.
//

import Foundation

final class HomeViewModel: ObservableObject {
    @Published var userName: String = "규희"
    @Published var avgScore: [Int] = [82, 89, 50, 32, 100, 30]
    @Published var prarticeListCount: Int = 1
}
