//
//  CircularProgressBarView.swift
//  Pree
//
//  Created by 이유현 on 8/1/25.
//

import Foundation

import SwiftUI

struct CircularProgressBarView: UIViewRepresentable {
    var value: Double

    func makeUIView(context: Context) -> CircularProgressBar {
        let view = CircularProgressBar()
        view.value = value
        return view
    }

    func updateUIView(_ uiView: CircularProgressBar, context: Context) {
        uiView.value = value
    }
}


#Preview {
    CircularProgressBarView(value: 0.2)
        .frame(width: 80, height: 80)
}

