//
//  BarGraphViewRepresentable.swift
//  Pree
//
//  Created by 이유현 on 7/31/25.
//

import Foundation
import SwiftUI

struct BarGraphViewRepresentable: UIViewRepresentable {
    var percentages: [CGFloat]

    func makeUIView(context: Context) -> BarGraphView {
        let barGraphView = BarGraphView()
        barGraphView.percentages = percentages
        return barGraphView
    }

    func updateUIView(_ uiView: BarGraphView, context: Context) {
        uiView.percentages = percentages
    }
}
