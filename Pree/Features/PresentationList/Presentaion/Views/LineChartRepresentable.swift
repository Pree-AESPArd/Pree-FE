//
//  LineChartRepresentable.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import SwiftUI

struct LineChartRepresentable: UIViewRepresentable {
    var scoreData: [Double]

    func makeUIView(context: Context) -> LineChartCustomView {
        let view = LineChartCustomView()
        return view
    }

    func updateUIView(_ uiView: LineChartCustomView, context: Context) {
        uiView.scoreData = scoreData
    }
}
