//
//  HomeViewModel.swift
//  Pree
//
//  Created by 이유현 on 7/31/25.
//

import Foundation

final class HomeViewModel: ObservableObject {
    @Published var userName: String = "규희"
    @Published var percentages: [CGFloat] = [82, 89, 50, 32, 100, 30]
    @Published var percentagesZero: [CGFloat] = [0, 0, 0, 0, 0, 0]
    @Published var prarticeListCount: Int = 1
    
    @Published var score: Double = 0.2
}
